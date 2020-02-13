#! /usr/bin/python3

import fasttext
import argparse
import logging

from collections import defaultdict


RULE_LID = "language-identification"
RULE_RATIO = "ratio"
RULE_OVERLAP = "overlap"
RULE_MIN_LENGTH = "min-length"
RULE_MAX_LENGTH = "max-length"

RULES = [RULE_LID,
         RULE_RATIO,
         RULE_OVERLAP,
         RULE_MIN_LENGTH,
         RULE_MAX_LENGTH]


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--threshold-ratio", type=float, help="Threshold for diverging number of tokens in source and target",
                        default=2.0, required=False)
    parser.add_argument("--threshold-min-length", type=float,
                        help="Threshold for minimum absolute number of tokens in either source or target",
                        default=3, required=False)
    parser.add_argument("--threshold-max-length", type=float,
                        help="Threshold for maxmimum absolute number of tokens in either source or target",
                        default=100, required=False)
    parser.add_argument("--threshold-overlap", type=float,
                        help="Threshold for overlap in percent between tokens of source and target",
                        default=0.5, required=False)
    parser.add_argument("--fasttext-model-path", type=str, default=None,
                        help="Path to fasttext model", required=False)

    parser.add_argument("--src-lang", type=str, required=True, help="Source language")
    parser.add_argument("--trg-lang", type=str, required=True, help="Target language")

    parser.add_argument("--input-src", type=str, required=True, help="Source language input file")
    parser.add_argument("--input-trg", type=str, required=True, help="Target language input file")

    parser.add_argument("--output-src", type=str, required=True, help="Source language output file")
    parser.add_argument("--output-trg", type=str, required=True, help="Target language output file")

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


def rule_ratio_ok(src_len, trg_len, ratio_threshold):

    if src_len == 0 or trg_len == 0:
        return False

    if src_len > trg_len:
        ratio = src_len / trg_len
    else:
        ratio = trg_len / src_len

    if ratio > ratio_threshold:
        return False

    return True

def rule_lid_ok(src_line, trg_line, src_lang, trg_lang, language_identifier):

    src_lang_pred = language_identifier.predict(src_line)

    if src_lang_pred != src_lang:
        return False

    trg_lang_pred = language_identifier.predict(trg_line)

    if trg_lang_pred != trg_lang:
        return False

    return True

def rule_max_length_ok(src_len, trg_len, threshold_max_length):

    if src_len > threshold_max_length:
        return False

    if trg_len > threshold_max_length:
        return False

    return True

def rule_min_length_ok(src_len, trg_len, threshold_min_length):

    if src_len < threshold_min_length:
        return False

    if trg_len < threshold_min_length:
        return False

    return True

def rule_overlap_ok(src_tokens, trg_tokens, src_len, trg_len, threshold_overlap):

    if src_len > trg_len:
        src_set = set(src_tokens)
        try:
            overlap = len(src_set.intersection(trg_tokens)) / trg_len
        except ZeroDivisionError:
            overlap = 0.0

        if overlap > threshold_overlap:
            return False
    else:
        trg_set = set(trg_tokens)
        try:
            overlap = len(trg_set.intersection(src_tokens)) / src_len
        except ZeroDivisionError:
            overlap = 0.0

        if overlap > threshold_overlap:
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

    with open(args.input_src, "r") as handle_input_src, open(args.input_trg, "r") as handle_input_trg, \
            open(args.output_src, "w") as handle_output_src, open(args.output_trg, "w") as handle_output_trg:
        for src_line, trg_line in zip(handle_input_src, handle_input_trg):

            lines_seen += 1

            if RULE_LID in args.rules:
                if not rule_lid_ok(src_line, trg_line, args.src_lang, args.trg_lang, language_identifier):
                    stats[RULE_LID] += 1
                    continue

            # split and count only if necessary
            if any([rule for rule in args.rules if rule != RULE_LID]):
                src_tokens = src_line.strip().split(" ")
                trg_tokens = trg_line.strip().split(" ")

                src_len = len(src_tokens)
                trg_len = len(trg_tokens)

            if RULE_MIN_LENGTH in args.rules:
                if not rule_min_length_ok(src_len, trg_len, args.threshold_min_length):
                    stats[RULE_MIN_LENGTH] += 1
                    continue

            if RULE_MAX_LENGTH in args.rules:
                if not rule_max_length_ok(src_len, trg_len, args.threshold_max_length):
                    stats[RULE_MAX_LENGTH] += 1
                    continue

            if RULE_RATIO in args.rules:
                if not rule_ratio_ok(src_len, trg_len, args.threshold_ratio):
                    stats[RULE_RATIO] += 1
                    continue

            if RULE_OVERLAP in args.rules:
                if not rule_overlap_ok(src_tokens, trg_tokens, src_len, trg_len, args.threshold_overlap):
                    stats[RULE_OVERLAP] += 1
                    continue

            # keep this sentence pair if it reaches this point

            lines_kept += 1

            handle_output_src.write(src_line)
            handle_output_trg.write(trg_line)

    logging.debug("Lines kept/seen: %d / %d" % (lines_kept, lines_seen))
    logging.debug("Reasons for skipping:")
    logging.debug(str(stats))


if __name__ == '__main__':
    main()
