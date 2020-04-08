#! /usr/bin/python3

import numpy as np

import argparse
import logging

from collections import defaultdict


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--params", type=str, help="Path to params.out (word-based translation probabilities)", required=True)
    parser.add_argument("--weights", type=str, help="Path to write weights", required=True)

    parser.add_argument("--source", type=str, help="Path to source sentences", required=True)
    parser.add_argument("--target", type=str, help="Path to source sentences", required=True)

    args = parser.parse_args()

    return args


def read_params(path):

    probs = defaultdict(lambda: defaultdict(float))

    with open(path, "r") as fin:
        for line in fin:
            parts = line.strip().split()

            source, target, prob = parts

            prob = float(prob)

            probs[target][source] = prob

    return probs


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)

    input_paths = [args.source, args.target]
    input_handles = [open(path, "r") for path in input_paths]

    output_handle = open(args.weights, "w")

    probs = read_params(args.params)

    for source, target in zip(*input_handles):

        source_tokens = source.strip().split(" ")
        target_tokens = target.strip().split(" ")

        weights = []

        len_target = len(target_tokens)

        for target_token in enumerate(target_tokens):

            source_probs = [probs[target_token][source_token] for source_token in source_tokens]

            assert len(source_probs) != 0

            max_log_prob = np.max(source_probs)

            max_prob = str(np.exp(max_log_prob))

            weights.append(max_prob)

        assert len(weights) == len_target

        output_handle.write(" ".join(weights) + "\n")


if __name__ == '__main__':
    main()
