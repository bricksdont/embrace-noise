#! /usr/bin/python3

import sys
import argparse
import logging


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--tag", type=str, help="Special indicator tag, e.g. to indicate language", required=True)

    args = parser.parse_args()

    return args


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    seen = 0

    for line in sys.stdin:

        seen += 1

        line = line.strip()

        if line == "":
            print(args.tag)
            continue

        tokens = line.split(" ")

        if tokens[0] == args.tag:
            logging.error("Sentence already has '%s' as first token. Do not run this script twice." % args.tag)
            sys.exit(1)
        else:
            tokens = [args.tag] + tokens

        line = " ".join(tokens)

        print(line)


if __name__ == '__main__':
    main()
