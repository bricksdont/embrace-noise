#! /usr/bin/python3

import random

import argparse
import logging


RANDOM = "random"
ONES = "ones"

METHODS = [RANDOM, ONES]


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--method", type=str, help="Number of lines to produce", required=True, choices=METHODS)
    parser.add_argument("--size", type=int, help="Number of lines to produce", required=True)

    args = parser.parse_args()

    return args


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)

    for _ in range(args.size):

        if args.method == RANDOM:
            value = random.random()
        else:
            value = 1.0

        print(value)


if __name__ == '__main__':
    main()
