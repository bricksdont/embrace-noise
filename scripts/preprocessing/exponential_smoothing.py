#! /usr/bin/python3

import sys
import argparse
import logging

import numpy as np


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--exp", type=float, help="Exponent for smoothing", required=True)

    args = parser.parse_args()

    return args


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    weights = []

    for line in sys.stdin:
        weight = float(line.strip())
        weights.append(weight)

    weights = np.asarray(weights)

    min_value = weights.min()
    max_value = weights.max()

    assert min_value >= 0.0
    assert max_value <= 1.0

    weights **= args.exp

    for weight in weights:
        sys.stdout.write(str(weight) + "\n")


if __name__ == '__main__':
    main()
