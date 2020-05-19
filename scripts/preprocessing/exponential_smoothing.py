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

    for line in sys.stdin:
        weights = [float(w) for w in line.strip().split(" ")]
        weights = np.asarray(weights)

        weights **= args.exp

        as_string = " ".join([str(w) for w in weights])
        sys.stdout.write(as_string + "\n")


if __name__ == '__main__':
    main()
