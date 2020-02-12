#! /usr/bin/python3

import fasttext
import argparse
import logging

from collections import defaultdict


RULE_LID = "language-identification"
RULE_MIN_LENGTH = "min-length"
RULE_MAX_LENGTH = "max-length"

RULES = [RULE_LID,
         RULE_MIN_LENGTH,
         RULE_MAX_LENGTH]


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--threshold-min-length", type=float,
                        help="Threshold for absolute number of tokens in either source or target",
                        default=3, required=False)
    parser.add_argument("--threshold-max-length", type=float,
                        help="Threshold for absolute number of tokens in either source or target",
                        default=100, required=False)
    parser.add_argument("--fasttext-model-path", type=str, default=None,
                        help="Path to fasttext model", required=False)

    parser.add_argument("--lang", type=str, required=True, help="Language ISO code")

    parser.add_argument("--input", type=str, required=True, help="Input file")
    parser.add_argument("--output", type=str, required=True, help="Output file")

    parser.add_argument("--rules", nargs="+", choices=RULES + ["all"], required=True)

    args = parser.parse_args()

    return args


class LanguageIdentifier(object):

    def __init__(self, model_path):

        self.model = fasttext.load_model(model_path)

    def predict(self, line):

        line = line.strip()

        labels, probs = self.model.predict(line)
        label = labels[0].split("__")[-1]

        return label

def rule_lid_ok(line, lang, language_identifier):

    lang_pred = language_identifier.predict(line)

    if lang_pred != lang:
        return False

    return True

def rule_max_length_ok(num_tokens, threshold_max_length):

    if num_tokens > threshold_max_length:
        return False

    return True

def rule_min_length_ok(num_tokens, threshold_min_length):

    if num_tokens < threshold_min_length:
        return False

    return True

def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    language_identifier = None

    if args.rules == ["all"]:
        args.rules = RULES

    if RULE_LID in args.rules:
        assert args.fasttext_model_path is not None, "If --rules %s, then --fasttext-model-path must be specified." % RULE_LID

        language_identifier = LanguageIdentifier(args.fasttext_model_path)

    stats = defaultdict(int)

    lines_seen = 0
    lines_kept = 0

    with open(args.input, "r") as handle_input, open(args.output, "w") as handle_output:
        for line in handle_input:

            lines_seen += 1

            if RULE_LID in args.rules:
                if not rule_lid_ok(line, args.lang, language_identifier):
                    stats[RULE_LID] += 1
                    continue

            # split and count only if necessary
            if any([rule for rule in args.rules if rule != RULE_LID]):
                tokens = line.strip().split(" ")
                num_tokens = len(tokens)

            if RULE_MIN_LENGTH in args.rules:
                if not rule_min_length_ok(num_tokens, args.threshold_min_length):
                    stats[RULE_MIN_LENGTH] += 1
                    continue

            if RULE_MAX_LENGTH in args.rules:
                if not rule_max_length_ok(num_tokens, args.threshold_max_length):
                    stats[RULE_MAX_LENGTH] += 1
                    continue

            # keep this sentence pair if it reaches this point

            lines_kept += 1

            handle_output.write(line)

    logging.debug("Lines kept/seen: %d / %d" % (lines_kept, lines_seen))
    logging.debug("Reasons for skipping:")
    logging.debug(str(stats))


if __name__ == '__main__':
    main()
