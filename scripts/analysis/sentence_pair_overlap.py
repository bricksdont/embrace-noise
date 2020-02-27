#! /usr/bin/python3

import sys
import argparse
import logging


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--inputs", type=str, nargs="+", help="Two files to be compared", required=True)

    args = parser.parse_args()

    return args


def intersection(a, b):
    """
    https://stackoverflow.com/questions/3697432/how-to-find-list-intersection

    :param a:
    :param b:
    :return:
    """

    return list(set(a) & set(b))


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    assert len(args.inputs) == 2, "Exactly two files must be compared"

    handles = [open(path) for path in args.inputs]

    lines = [handle.readlines() for handle in handles]

    num_lines = len(lines[0])

    assert num_lines == len(lines[1]), "Files must have the same number of lines"

    num_intersecting = intersection(*lines)

    logging.debug("Number of intersecting lines / total: %d / %d" % (num_intersecting, num_lines))

if __name__ == '__main__':
    main()
