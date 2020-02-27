#! /usr/bin/python3

import sys
import argparse
import logging


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--inputs", type=str, nargs="+", help="Two files to be compared", required=True)
    parser.add_argument("--strict", action="store_true", help="Require files to have same number of lines", required=False,
                        default=False)

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

    num_lines = [len(l) for l in lines]

    num_unique_lines = [len(set(l)) for l in lines]

    if args.strict:
        assert num_lines[0] == num_lines[1], "Files must have the same number of lines"

    num_intersecting = len(intersection(*lines))

    logging.debug("Overlap lines: %d" % num_intersecting)

    for name, nl, nlu in zip(["File A", "File B"], num_lines, num_unique_lines):
        logging.debug("%s\tUnique lines / total lines: %d / %d" % (name, nlu, nl))

if __name__ == '__main__':
    main()
