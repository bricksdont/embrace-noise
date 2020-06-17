#! /usr/bin/python3

import re
import os

import argparse
import logging

from typing import Optional, Pattern
from collections import namedtuple


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--folder", type=str, help="Folder to search for BLEU results", required=True)
    parser.add_argument("--subset-regex", type=str, help="Only display results for model names that match regex",
                        required=False)
    parser.add_argument("--num-tabs", type=int, help="Number of tabs between values",
                        required=False, default=1)
    args = parser.parse_args()

    return args


Result = namedtuple('Result', ["name", "dev", "test"])


def tab(r: Result, num_tabs: int = 1) -> str:
    """

    :param r:
    :param num_tabs:
    :return:
    """
    parts = [r.name + "\t", r.dev, r.test]
    joiner = "\t" * num_tabs
    line = joiner.join(parts)

    return line


def extract_bleu_from_file(path: str) -> str:
    """

    :param path:
    :return:
    """
    with open(path, "r") as handle:
        line = handle.readline()
        parts = line.split(" ")
        bleu = parts[2]

        return bleu


def name_matches_regex(name: str, regex: Optional[Pattern]) -> bool:
    """

    :param name:
    :param regex:
    :return:
    """

    if regex is None:
        return True

    if regex.match(name):
        return True
    else:
        return False


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    if args.subset_regex is not None:
        compiled_regex = re.compile(args.subset_regex)
    else:
        compiled_regex = None

    results = []

    for root, dirs, _ in os.walk(args.folder):
        for dir_name in dirs:
            if name_matches_regex(dir_name, compiled_regex):

                dev_file_name = os.path.join(root, dir_name, "dev.bleu")
                dev_bleu = extract_bleu_from_file(dev_file_name)

                test_file_name = os.path.join(root, dir_name, "test.bleu")
                test_bleu = extract_bleu_from_file(test_file_name)

                r = Result(dir_name, dev_bleu, test_bleu)
                results.append(r)

    joiner = "\t" + args.num_tabs
    print(joiner.join(["NAME\t", "DEV", "TEST"]))

    for r in results:
        print(tab(r, args.num_tabs))


if __name__ == '__main__':
    main()
