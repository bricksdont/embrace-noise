#! /usr/bin/python3

import time
import argparse
import logging


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--inputs", type=str, nargs="+", help="Two files to be compared", required=True)
    parser.add_argument("--strict", action="store_true", help="Require files to have same number of lines", required=False,
                        default=False)
    parser.add_argument("--fast", action="store_true", help="Simply compute number of overlapping lines without enumerating them",
                        required=False, default=False)
    parser.add_argument("--output", type=str,
                        help="Print to STDOUT overlapping lines, or ones that don't",
                        required=False, default="overlap", choices=["overlap", "no-overlap"])

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

    tic = time.time()

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    assert len(args.inputs) == 2, "Exactly two files must be compared"

    handles = [open(path) for path in args.inputs]

    lines = [handle.readlines() for handle in handles]

    num_lines = [len(l) for l in lines]

    num_unique_lines = [len(set(l)) for l in lines]

    seen = 0

    if args.strict:
        assert num_lines[0] == num_lines[1], "Files must have the same number of lines"

    if args.fast:
        num_intersecting = len(intersection(*lines))
    else:
        num_intersecting = 0

        for line in lines[0]:
            if line in lines[1]:
                num_intersecting += 1
                if args.output == "overlap":
                    print(line)
            else:
                if args.output == "no-overlap":
                    print(line)

            seen += 1

            if seen % 50000 == 0:
                logging.debug("%d / %d" % (seen, num_lines[0]))

    logging.debug("Overlap\t: %d" % num_intersecting)

    for name, nl, nlu in zip(["File A", "File B"], num_lines, num_unique_lines):
        logging.debug("%s\tUnique lines / total lines: %d / %d" % (name, nlu, nl))

    toc = time.time() - tic

    logging.debug("Time taken: %f seconds" % toc)

if __name__ == '__main__':
    main()
