#! /usr/bin/python3

# Implementation of Dual Conditional Cross-entropy Filtering:
# https://arxiv.org/pdf/1809.00197.pdf

import argparse
import logging
import numpy as np
import itertools


METHOD_ADQ = "adq"
METHOD_ADQ_DOM = "adq-dom"

METHODS = [METHOD_ADQ,
           METHOD_ADQ_DOM]


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--scores-nmt-forward", type=str, help="File with forward scores, one float per line", required=True)
    parser.add_argument("--scores-nmt-backward", type=str, help="File with backward scores, one float per line", required=True)

    parser.add_argument("--scores-lm-indomain", type=str, help="File with in-domain LM scores, one float per line", required=False,
                        default=None)
    parser.add_argument("--scores-lm-outdomain", type=str, help="File with out-of-domain LM scores, one float per line", required=False,
                        default=None)

    parser.add_argument("--method", type=str, help="Scoring method", choices=METHODS, required=False, default=METHOD_ADQ)

    parser.add_argument("--output", type=str, help="Output file for combined DCCE scores", required=True)

    parser.add_argument("--src-lang", type=str, help="Source language", required=True)
    parser.add_argument("--trg-lang", type=str, help="Target language", required=True)

    # algorithm hyperparameters

    parser.add_argument("--domain-filter-cutoff", type=float, help="Cutoff for in-domain/out-of-domain perplexity difference filter",
                        required=False, default=0.25)


    args = parser.parse_args()

    return args


def adequacy(score_forward: float, score_backward: float):
    """
    General formula:

    adq(x, y) = exp(-(
                        | H_A(y|x) - H_B(x|y) | +
                        1/2 * (H_A(y|x) + H_B(x|y))
                        ))
    """

    ce_difference = score_forward - score_backward
    ce_sum = score_forward + score_backward

    combined = abs(ce_difference) + (0.5 * ce_sum)

    return np.exp(-combined)

def _dom_prime(score_indomain, score_outdomain):
    """
        General formula:

        dom_prime(y) = exp(
                                - (H_i(y) - H_o(y))
        )
    """

    difference = score_indomain - score_outdomain

    return np.exp(- difference)

def _dom(score_indomain, score_outdomain):
    """
    dom(y) = min(dom_prime(y), 1.0)
    """
    return min(_dom_prime(score_indomain, score_outdomain), 1.0)

def _cut(score, cutoff):

    if score >= cutoff:
        return score
    else:
        return cutoff

def dom_with_cutoff(score_indomain, score_outdomain, cutoff):
    """
    General formula:

    dom_prime(y) = exp(
                            - (H_i(y) - H_o(y))
    )

    dom(y) = min(dom_prime(y), 1.0)

    dom_cutoff(y) = _cut(dom(y), cutoff)
    """

    return _cut(_dom(score_indomain, score_outdomain), cutoff)

def dual_conditional_cross_entropy(score_nmt_forward,
                                   score_nmt_backward,
                                   score_lm_indomain,
                                   score_lm_outdomain,
                                   dom_cutoff):

    adequacy_score = adequacy(score_nmt_forward, score_nmt_backward)

    dom_score = 1.0

    if None not in [score_lm_indomain, score_lm_outdomain]:
        dom_score = dom_with_cutoff(score_lm_indomain, score_lm_outdomain, dom_cutoff)

    return adequacy_score * dom_score

def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    if args.method == METHOD_ADQ_DOM:
        assert None not in [args.scores_lm_indomain, args.scores_lm_outdomain], "if --method=%s, language model scores " \
                                                                                "--scores-lm-indomain/--scores-lm-outdomain " \
                                                                                "cannot be None" % METHOD_ADQ_DOM

    files = [args.scores_nmt_forward, args.scores_nmt_backward, args.scores_lm_indomain, args.scores_lm_outdomain]

    input_handles = [open(file, "r") if file is not None else [None] for file in files ]

    with open(args.output, "w") as handle_output:

        for scores in itertools.zip_longest(*input_handles):

            scores = [float(score) for score in scores]

            score_nmt_forward, score_nmt_backward, score_lm_indomain, score_lm_outdomain = scores

            score = dual_conditional_cross_entropy(score_nmt_forward,
                                                   score_nmt_backward,
                                                   score_lm_indomain,
                                                   score_lm_outdomain,
                                                   args.domain_filter_cutoff)

            handle_output.write("%f\n" % score)


if __name__ == '__main__':
    main()