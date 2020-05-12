#! /bin/bash

# all sample 1

python3 display.py --source train.bpe.sample.de --target train.bpe.sample.en \
    --weights raw_paracrawl.100.filtered.baseline.ignore/sample \
              raw_paracrawl.100.filtered.baseline.only/sample \
              raw_paracrawl.100.filtered.baseline.mean/sample \
              raw_paracrawl.100.filtered.baseline.min/sample \
              raw_paracrawl.100.filtered.baseline.max/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.ignore/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.only/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.min/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.max/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.ignore/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.only/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.min/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.max/sample \
              raw_paracrawl.100.filtered.baseline.word_level.ignore/sample \
              raw_paracrawl.100.filtered.baseline.word_level.only/sample \
              raw_paracrawl.100.filtered.baseline.word_level.mean/sample \
              raw_paracrawl.100.filtered.baseline.word_level.min/sample \
              raw_paracrawl.100.filtered.baseline.word_level.max/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.ignore/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.only/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.min/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.max/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.ignore/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.only/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.min/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max/sample \
    --weights-names baseline.ignore baseline.only baseline.mean baseline.min baseline.max \
                    all.ignore all.only all.mean all.min all.max \
                    filtered.ignore filtered.only filtered.mean filtered.min filtered.max \
                    baseline.word_level.ignore baseline.word_level.only baseline.word_level.mean baseline.word_level.min baseline.word_level.max \
                    all.word_level.ignore all.word_level.only all.word_level.mean all.word_level.min all.word_level.max \
                    filtered.word_level.ignore filtered.word_level.only filtered.word_level.mean filtered.word_level.min filtered.word_level.max > \
    results.all.sample1.csv

# all sample 2

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.baseline.ignore/sample2 \
              raw_paracrawl.100.filtered.baseline.only/sample2 \
              raw_paracrawl.100.filtered.baseline.mean/sample2 \
              raw_paracrawl.100.filtered.baseline.min/sample2 \
              raw_paracrawl.100.filtered.baseline.max/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.ignore/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.only/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.min/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.max/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.ignore/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.only/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.min/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.max/sample2 \
              raw_paracrawl.100.filtered.baseline.word_level.ignore/sample2 \
              raw_paracrawl.100.filtered.baseline.word_level.only/sample2 \
              raw_paracrawl.100.filtered.baseline.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.baseline.word_level.min/sample2 \
              raw_paracrawl.100.filtered.baseline.word_level.max/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.ignore/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.only/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.min/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.max/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.ignore/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.only/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.min/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max/sample2 \
    --weights-names baseline.ignore baseline.only baseline.mean baseline.min baseline.max \
                    all.ignore all.only all.mean all.min all.max \
                    filtered.ignore filtered.only filtered.mean filtered.min filtered.max \
                    baseline.word_level.ignore baseline.word_level.only baseline.word_level.mean baseline.word_level.min baseline.word_level.max \
                    all.word_level.ignore all.word_level.only all.word_level.mean all.word_level.min all.word_level.max \
                    filtered.word_level.ignore filtered.word_level.only filtered.word_level.mean filtered.word_level.min filtered.word_level.max > \
    results.all.sample2.csv

# trained on clean data, subword, compare combination methods

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.baseline.ignore/sample2 \
              raw_paracrawl.100.filtered.baseline.only/sample2 \
              raw_paracrawl.100.filtered.baseline.mean/sample2 \
              raw_paracrawl.100.filtered.baseline.min/sample2 \
              raw_paracrawl.100.filtered.baseline.max/sample2 \
    --weights-names baseline.ignore baseline.only baseline.mean baseline.min baseline.max  > \
    results.compare_methods.sample2.csv

# subword, MEAN method, compare training data

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.baseline.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.mean/sample2 \
    --weights-names baseline.mean all.mean filtered.mean > \
    results.compare_training_data.sample2.csv

# trained on clean data, MEAN method, compare subword vs. word level

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.baseline.mean/sample2 \
              raw_paracrawl.100.filtered.baseline.word_level.mean/sample2 \
    --weights-names baseline.mean baseline.word_level.mean > \
    results.compare_subword_word.sample2.csv
