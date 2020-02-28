#! /usr/bin/python3

import argparse
import logging

def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--inputs", type=str, nargs="+", help="Two files to be compared", required=True)

    args = parser.parse_args()

    return args

def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    assert len(args.inputs) == 2, "Exactly two files must be compared"

    handles = [open(path) for path in args.inputs]

    for line1, line2 in zip(*handles):
        if line1 == line2:
            continue
        else:
            print(line1.strip())
            print(line2.strip())
            print()

if __name__ == '__main__':
    main()