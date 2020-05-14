#! /usr/bin/python3

import numpy as np

import time
import argparse
import logging

from collections import defaultdict
from typing import List


VERY_NEGATIVE_LOGPROB = -100.0
NULL_TOKEN_STRING = "<eps>"

USE_REVERSE_METHODS = ["min", "max", "mean", "geomean", "ignore", "only"]
SMOOTH_METHODS = ["pre-3", "post-3", "pre-3-edge", "post-3-edge"]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()

    parser.add_argument("--params", type=str, help="Path to params.out (word-based translation probabilities)",
                        required=True)
    parser.add_argument("--params-reverse", type=str, help="Path to reverse model params.out (word-based translation "
                                                           "probabilities)",
                        required=True)
    parser.add_argument("--weights", type=str, help="Path to write weights", required=True)

    parser.add_argument("--source", type=str, help="Path to source sentences", required=True)
    parser.add_argument("--target", type=str, help="Path to source sentences", required=True)

    parser.add_argument("--use-reverse-method", type=str, help="How to factor in the reverse alignment model.",
                        required=False, default="mean",
                        choices=USE_REVERSE_METHODS)
    parser.add_argument("--word-level", action="store_true", help="Use if probs are word-level and need to be"
                                                                  "propagated to subwords", required=False,
                        default=False)
    parser.add_argument("--smooth-method", type=str,
                        help="Average weights to smooth over window", required=False,
                        default=None, choices=SMOOTH_METHODS)

    args = parser.parse_args()

    return args


def moving_average(input_list: List[float], window_size: int = 3, ignore_edges: bool = False) -> np.array:

    input_array = np.array(input_list)

    if ignore_edges:
        edge_start = input_array[:1]
        edge_end = input_array[-1:]

        conv = moving_average(input_array[1:-1], window_size=window_size, ignore_edges=False)

    else:
        edge_start = np.mean(input_array[:2], keepdims=True)
        edge_end = np.mean(input_array[-2:], keepdims=True)

        conv = np.convolve(input_array, np.ones((window_size,)) / window_size, mode='valid')

    averaged_array = np.concatenate([edge_start, conv, edge_end])

    assert input_array.shape == averaged_array.shape

    return averaged_array


def read_params(path):

    probs = defaultdict(dict)

    with open(path, "r") as fin:
        for line in fin:
            parts = line.strip().split()

            source, target, prob = parts

            prob = float(prob)

            probs[source][target] = prob

    return probs


def get_probs(target_token, source_tokens, probs, reverse=False):

    extracted_probs = []
    inserted_default_prob = 0

    source_tokens = [NULL_TOKEN_STRING] + source_tokens

    if reverse:

        sub_dict = probs[target_token]

        for source_token in source_tokens:

            if source_token in sub_dict.keys():
                prob = sub_dict[source_token]
            else:
                prob = VERY_NEGATIVE_LOGPROB
                inserted_default_prob += 1

            extracted_probs.append(prob)

    else:

        for source_token in source_tokens:

            sub_dict = probs[source_token]

            if target_token in sub_dict.keys():
                prob = sub_dict[target_token]
            else:
                prob = VERY_NEGATIVE_LOGPROB
                inserted_default_prob += 1

            extracted_probs.append(prob)

    extracted_probs = np.asarray(extracted_probs)

    # remove log scale

    extracted_probs = np.exp(extracted_probs)

    return extracted_probs, inserted_default_prob


def combine_probs(probs_forward, probs_reverse, use_reverse_method):

    if use_reverse_method == "ignore":
        return probs_forward
    if use_reverse_method == "only":
        return probs_reverse
    elif use_reverse_method == "min":
        return np.minimum(probs_forward, probs_reverse)
    elif use_reverse_method == "max":
        return np.maximum(probs_forward, probs_reverse)
    elif use_reverse_method == "mean":
        return np.mean([probs_forward, probs_reverse], axis=0)
    elif use_reverse_method == "geomean":
        return np.multiply(probs_forward, probs_reverse) ** 0.5
    else:
        raise NotImplementedError


def main():

    tic = time.time()

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    input_paths = [args.source, args.target]
    input_handles = [open(path, "r") for path in input_paths]

    output_handle = open(args.weights, "w")

    probs = read_params(args.params)
    probs_reverse = read_params(args.params_reverse)

    lines_seen = 0

    inserted_default_prob_global = 0

    for source, target in zip(*input_handles):

        if args.word_level:
            # remove BPE from tokens but save a copy of target subwords
            target_subwords = target.strip().split(" ")
            source = source.replace("@@ ", "").replace("@@", "")
            target = target.replace("@@ ", "").replace("@@", "")
        else:
            target_subwords = []

        source_tokens = source.strip().split(" ")
        target_tokens = target.strip().split(" ")

        weights = []

        len_target = len(target_tokens)

        for target_token in target_tokens:

            source_probs_forward, inserted_default_prob = get_probs(target_token, source_tokens, probs)
            inserted_default_prob_global += inserted_default_prob

            source_probs_reverse, inserted_default_prob = get_probs(target_token, source_tokens, probs_reverse,
                                                                    reverse=True)
            inserted_default_prob_global += inserted_default_prob

            assert len(source_probs_forward) != 0
            assert len(source_probs_reverse) != 0

            source_probs = combine_probs(source_probs_forward, source_probs_reverse, args.use_reverse_method)

            max_prob = np.max(source_probs)

            weights.append(max_prob)

        assert len(weights) == len_target

        if args.word_level:

            if args.smooth_method == "pre-3":
                weights = moving_average(weights, window_size=3, ignore_edges=True)
            elif args.smooth_method == "pre-3-edge":
                weights = moving_average(weights, window_size=3, ignore_edges=False)

            subword_weights = []

            # propagate weights to target subwords
            weight_index = 0
            for target_subword in target_subwords:
                subword_weights.append(weights[weight_index])
                if "@@" in target_subword:
                    # do not advance weight index
                    continue
                else:
                    weight_index += 1

            weights = subword_weights

            if args.smooth_method == "post-3":
                weights = moving_average(weights, window_size=3, ignore_edges=True)
            elif args.smooth_method == "post-3-edge":
                weights = moving_average(weights, window_size=3, ignore_edges=False)

        weights = [str(w) for w in weights]

        output_handle.write(" ".join(weights) + "\n")

        lines_seen += 1

        if lines_seen % 100000 == 0:
            intermediate_toc = time.time() - tic
            logging.debug("Lines seen: %d, time taken so far: %f seconds" % (lines_seen, intermediate_toc))

    toc = time.time() - tic

    logging.debug("Number of times inserted default prob: %d" % inserted_default_prob_global)

    logging.debug("Overall time taken: %f seconds" % toc)


if __name__ == '__main__':
    main()
