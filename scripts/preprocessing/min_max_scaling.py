#! /usr/bin/python3

import sys

import numpy as np

scores = []

for line in sys.stdin:
    score = float(line.strip())
    scores.append(score)

scores = np.asarray(scores)

min_value = scores.min()
max_value = scores.max()

scores_scaled = (scores - min_value) / (max_value - min_value)

for score in scores_scaled:
    print(score)
