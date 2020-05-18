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
SMOOTH_METHODS = ["mean", "geomean"]


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


def rolling_window_lastaxis(a, window):
    """
    https://stackoverflow.com/questions/4936620/using-strides-for-an-efficient-moving-average-filter

    Directly taken from Erik Rigtorp's post to numpy-discussion.
    <http://www.mail-archive.com/numpy-discussion@scipy.org/msg29450.html>"""
    if window < 1:
        raise ValueError
    if window > a.shape[-1]:
        raise ValueError
    shape = a.shape[:-1] + (a.shape[-1] - window + 1, window)
    strides = a.strides + (a.strides[-1],)
    return np.lib.stride_tricks.as_strided(a, shape=shape, strides=strides)


def rolling_window(a, window):
    """
    https://stackoverflow.com/questions/4936620/using-strides-for-an-efficient-moving-average-filter
    :param a:
    :param window:
    :return:
    """
    if not hasattr(window, '__iter__'):
        return rolling_window_lastaxis(a, window)
    for i, win in enumerate(window):
        if win > 1:
            a = a.swapaxes(i, -1)
            a = rolling_window_lastaxis(a, win)
            a = a.swapaxes(-2, i)
    return a


def mean_function(input_array: np.array, mean_type: str = "mean",
                  keepdims: bool = False, axis: int = -1):

    if mean_type == "mean":
        return np.mean(input_array, keepdims=keepdims, axis=axis)
    elif mean_type == "geomean":
        combined_array = np.exp(np.sum(np.log(input_array), axis=axis) / input_array.shape[axis])

        if keepdims:
            return np.expand_dims(combined_array, axis=0)
        else:
            return combined_array
    else:
        raise NotImplementedError


def moving_average(input_list: List[float], window_size: int = 3, mean_type: str = "mean") -> np.array:

    input_array = np.array(input_list)

    extended_input_array = np.concatenate([input_array[:1], input_array, input_array[-1:]])
    strides = rolling_window(extended_input_array, window_size)

    averaged_array = mean_function(strides, mean_type=mean_type, keepdims=False, axis=-1)

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
        return np.max(probs_forward)
    elif use_reverse_method == "only":
        return np.max(probs_reverse)

    max_forward = np.max(probs_forward)
    max_reverse = np.max(probs_reverse)

    max_combined = np.asarray([max_forward, max_reverse])

    if use_reverse_method == "min":
        return np.min(max_combined)
    elif use_reverse_method == "max":
        return np.max(max_combined)
    elif use_reverse_method == "mean":
        return mean_function(max_combined, mean_type="mean", keepdims=False, axis=-1)
    elif use_reverse_method == "geomean":
        return mean_function(max_combined, mean_type="geomean", keepdims=False, axis=-1)
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

            max_prob = combine_probs(source_probs_forward, source_probs_reverse, args.use_reverse_method)

            weights.append(max_prob)

        assert len(weights) == len_target

        if args.word_level:

            if args.smooth_method is not None:
                weights = moving_average(weights, window_size=3, mean_type=args.smooth_method)

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
