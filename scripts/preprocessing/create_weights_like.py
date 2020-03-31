#! /usr/bin/python3

import random

import argparse
import logging


RANDOM = "random"
ONES = "ones"

METHODS = [RANDOM, ONES]


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--method", type=str, help="Random or 10 weight", required=True, choices=METHODS)
    parser.add_argument("--like", type=str, help="Create one weight for each token in this file.", required=True)

    args = parser.parse_args()

    return args


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)

    def random_value():
        if args.method == RANDOM:
            return str(random.random())
        else:
            return str(1.0)

    with open(args.like, "r") as fin:

        for line in fin:
            tokens = line.strip().split(" ")
            values = [random_value() for _ in tokens]

            print(" ".join(values))


if __name__ == '__main__':
    main()
