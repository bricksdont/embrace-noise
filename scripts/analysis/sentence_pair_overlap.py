#! /usr/bin/python3

import time
import argparse
import logging

import numpy as np


COMMON = "common"
ONLY_A = "only-a"
ONLY_B = "only-b"
NOOUT = "no-out"

OUTPUT_OPTIONS = [COMMON,
                  ONLY_A,
                  ONLY_B,
                  NOOUT]

def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--inputs", type=str, nargs="+", help="Two files to be compared", required=True)
    parser.add_argument("--strict", action="store_true", help="Require files to have same number of lines", required=False,
                        default=False)
    parser.add_argument("--output", type=str,
                        help="Print to STDOUT common lines, or only appearing in A or B",
                        required=False, default=NOOUT, choices=OUTPUT_OPTIONS)

    args = parser.parse_args()

    return args


def intersection(a, b):
    """
    Returns elements common to a and b.

    https://stackoverflow.com/questions/3697432/how-to-find-list-intersection

    :param a:
    :param b:
    :return:
    """
    return list(set(a) & set(b))

def set_difference(a, b):
    """
    Returns all elements only in list a, but not b.

    https://stackoverflow.com/a/41127279/1987598

    :param a:
    :param b:
    :return:
    """
    return np.setdiff1d(a, b, assume_unique=True).tolist()


def main():

    tic = time.time()

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    assert len(args.inputs) == 2, "Exactly two files must be compared"

    handles = [open(path) for path in args.inputs]

    lines = [handle.readlines() for handle in handles]

    num_lines = [len(l) for l in lines]

    num_unique_lines = [len(set(l)) for l in lines]

    if args.strict:
        assert num_lines[0] == num_lines[1], "Files must have the same number of lines"

    intersecting = intersection(*lines)

    num_intersecting = len(intersecting)

    if args.output == COMMON:
        for line in intersecting:
                print(line, end='')
    elif args.output == ONLY_A:
        difference = set_difference(lines[0], lines[1])
        for line in difference:
                print(line, end='')
    elif args.output == ONLY_B:
        difference = set_difference(lines[1], lines[0])
        for line in difference:
            print(line, end='')

    logging.debug("Overlap\t: %d" % num_intersecting)

    for name, nl, nlu in zip(["File A", "File B"], num_lines, num_unique_lines):
        logging.debug("%s\tUnique lines / total lines: %d / %d" % (name, nlu, nl))

    toc = time.time() - tic

    logging.debug("Time taken: %f seconds" % toc)

if __name__ == '__main__':
    main()
