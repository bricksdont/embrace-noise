#! /usr/bin/python3

import random

import argparse
import logging

def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--source", type=str, help="source BPE", required=True)
    parser.add_argument("--target", type=str, help="target BPE", required=True)
    parser.add_argument("--weights", type=str, nargs="+", help="Sentence or word-level weights.", required=True)
    parser.add_argument("--weights-names", type=str, nargs="+", help="names for weights", required=True)

    args = parser.parse_args()

    return args


def tab(line):
    tokens = line.strip().split(" ")
    new_line = "\t".join(tokens)

    return new_line


def check_length_equal(strings):

    lengths = [len(s.strip().split(" ")) for s in strings]

    assert len(set(lengths)) == 1, "Lengths are not equal: %s" % str(strings)


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    assert len(args.weights) == len(args.weights_names)

    weights_handles = [open(w, "r") for w in args.weights]

    with open(args.source, "r") as source_handle, open(args.target, "r") as target_handle:

            for source, target in zip(source_handle, target_handle):

                next_weights = [next(h) for h in weights_handles]

                check_length_equal([target] + next_weights)

                source = tab("SRC: " + source)
                target = tab("TRG: " + target)

                weights = [tab(n.upper() + " " + w) for n,w in zip(args.weights_names, next_weights)]

                print(source)
                print(target)

                for w in weights:
                    assert " " not in w, "%s" % w
                    print(w)

                print()


if __name__ == '__main__':
    main()
