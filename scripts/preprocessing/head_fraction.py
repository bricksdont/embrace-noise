#! /usr/bin/python3

import sys
import argparse
import logging


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--fraction", type=float, help="Fraction of input file in terms of lines to extract, from beginning.", required=True)
    parser.add_argument("--size", type=int, help="Number of lines in input.", required=True)

    args = parser.parse_args()

    return args


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    desired_size = args.size * args.fraction

    logging.debug("Desired size/total: %f/%d" % (desired_size, args.size))

    seen = 0

    for line in sys.stdin:

        if seen >= desired_size:
            break

        sys.stdout.write(line)

        seen += 1

if __name__ == '__main__':
    main()
