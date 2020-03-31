#! /usr/bin/python3

import argparse
import logging


HIGH_WEIGHT = "1.0"
LOW_WEIGHT = "0.5"


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--alignments", type=str, help="Path to read alignments", required=True)
    parser.add_argument("--weights", type=str, help="Path to write weights", required=True)

    parser.add_argument("--source", type=str, help="Path to source sentences", required=True)
    parser.add_argument("--target", type=str, help="Path to source sentences", required=True)

    args = parser.parse_args()

    return args


def read_alignments(line: str):

    alignment_dict = {}

    pairs = line.strip().split(" ")

    for pair in pairs:

        source_index, target_index = pair[0], pair[2]

        alignment_dict[target_index] = source_index

    return alignment_dict


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)

    input_paths = [args.alignments, args.source, args.target]

    input_handles = [open(path, "r") for path in input_paths]

    output_handle = open(args.weights, "w")

    for alignment, source, target in zip(*input_handles):

        target_tokens = target.strip().split(" ")

        weights = []

        alignment_dict = read_alignments(alignment)

        for index, token in enumerate(target_tokens):
            if index not in alignment_dict.keys():
                weights.append(LOW_WEIGHT)
            else:
                weights.append(HIGH_WEIGHT)

        output_handle.write(" ".join(weights) + "\n")


if __name__ == '__main__':
    main()
