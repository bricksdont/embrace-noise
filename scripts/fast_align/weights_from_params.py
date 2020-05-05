#! /usr/bin/python3

import numpy as np

import time
import argparse
import logging

from collections import defaultdict


VERY_NEGATIVE_LOGPROB = -100.0
NULL_TOKEN_STRING = "<eps>"

USE_REVERSE_METHODS=["min", "max", "mean", "ignore", "only"]


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--params", type=str, help="Path to params.out (word-based translation probabilities)", required=True)
    parser.add_argument("--params-reverse", type=str, help="Path to reverse model params.out (word-based translation probabilities)",
                        required=True)
    parser.add_argument("--weights", type=str, help="Path to write weights", required=True)

    parser.add_argument("--source", type=str, help="Path to source sentences", required=True)
    parser.add_argument("--target", type=str, help="Path to source sentences", required=True)

    parser.add_argument("--use-reverse-method", type=str, help="Path to source sentences", required=False, default="mean")

    args = parser.parse_args()

    return args


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

            sub_dict= probs[source_token]

            if target_token in sub_dict.keys():
                prob= sub_dict[target_token]
            else:
                prob = VERY_NEGATIVE_LOGPROB
                inserted_default_prob += 1

            extracted_probs.append(prob)

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

        source_tokens = source.strip().split(" ")
        target_tokens = target.strip().split(" ")

        weights = []

        len_target = len(target_tokens)

        for target_token in target_tokens:

            source_probs_forward, inserted_default_prob = get_probs(target_token, source_tokens, probs)
            inserted_default_prob_global += inserted_default_prob

            source_probs_reverse, inserted_default_prob = get_probs(target_token, source_tokens, probs_reverse, reverse=True)
            inserted_default_prob_global += inserted_default_prob

            assert len(source_probs_forward) != 0
            assert len(source_probs_reverse) != 0

            source_probs = combine_probs(source_probs_forward, source_probs_reverse, args.use_reverse_method)

            max_log_prob = np.max(source_probs)

            max_prob = str(np.exp(max_log_prob))

            weights.append(max_prob)

        assert len(weights) == len_target

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
