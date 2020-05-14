#! /bin/bash

# all sample 1

python3 display.py --source train.bpe.sample.de --target train.bpe.sample.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.ignore/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.only/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.min/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.max/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.geomean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.ignore/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.only/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.min/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.max/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.geomean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.ignore/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.only/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.min/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.max/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.geomean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.ignore/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.only/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.min/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.ignore.smooth/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.only.smooth/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.mean.smooth/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.min.smooth/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.max.smooth/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.geomean.smooth/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.ignore.smooth/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.only.smooth/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.smooth/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.min.smooth/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max.smooth/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean.smooth/sample \
    --weights-names all.ignore all.only all.mean all.min all.max all.geomean \
                    filtered.ignore filtered.only filtered.mean filtered.min filtered.max filtered.geomean \
                    all.word_level.ignore all.word_level.only all.word_level.mean all.word_level.min all.word_level.max all.word_level.geomean \
                    filtered.word_level.ignore filtered.word_level.only filtered.word_level.mean filtered.word_level.min filtered.word_level.max filtered.word_level.geomean \
                    all.word_level.ignore.smooth all.word_level.only.smooth all.word_level.mean.smooth all.word_level.min.smooth all.word_level.max.smooth all.word_level.geomean.smooth \
                    filtered.word_level.ignore.smooth filtered.word_level.only.smooth filtered.word_level.mean.smooth filtered.word_level.min.smooth filtered.word_level.max.smooth filtered.word_level.geomean.smooth > \
    results.all.sample1.csv

# all sample 2

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.ignore/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.only/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.min/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.max/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.geomean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.ignore/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.only/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.min/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.max/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.geomean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.ignore/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.only/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.min/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.max/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.geomean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.ignore/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.only/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.min/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.ignore.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.only.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.mean.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.min.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.max.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.geomean.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.ignore.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.only.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.min.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean.smooth/sample2 \
    --weights-names all.ignore all.only all.mean all.min all.max all.geomean \
                    filtered.ignore filtered.only filtered.mean filtered.min filtered.max filtered.geomean \
                    all.word_level.ignore all.word_level.only all.word_level.mean all.word_level.min all.word_level.max all.word_level.geomean \
                    filtered.word_level.ignore filtered.word_level.only filtered.word_level.mean filtered.word_level.min filtered.word_level.max filtered.word_level.geomean \
                    all.word_level.ignore.smooth all.word_level.only.smooth all.word_level.mean.smooth all.word_level.min.smooth all.word_level.max.smooth all.word_level.geomean.smooth \
                    filtered.word_level.ignore.smooth filtered.word_level.only.smooth filtered.word_level.mean.smooth filtered.word_level.min.smooth filtered.word_level.max.smooth filtered.word_level.geomean.smooth > \
    results.all.sample2.csv

# trained on filtered data, word level, compare combination methods

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.ignore/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.only/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.min/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean/sample2 \
    --weights-names filtered.ignore filtered.only filtered.mean filtered.min filtered.max filtered.geomean > \
    results.compare_methods.sample2.csv

# subword, MEAN method, compare training data

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.baseline.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.mean/sample2 \
    --weights-names baseline.mean all.mean filtered.mean > \
    results.compare_training_data.sample2.csv

# word, MEAN method, compare training data

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.baseline.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample2 \
    --weights-names baseline.word_level.mean all.word_level.mean filtered.word_level.mean > \
    results.compare_training_data_word_level.sample2.csv

# trained on filtered data, MEAN method, compare subword vs. word level

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample2 \
    --weights-names filtered.mean filtered.word_level.mean > \
    results.compare_subword_word.sample2.csv

# trained on filtered data, MEAN method, word level, compare smoothness

python3 display.py --source train.bpe.sample.de --target train.bpe.sample.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.pre-3/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.pre-3-edge/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.post-3/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.post-3-edge/sample \
    --weights-names filtered.word_level.mean filtered.word_level.mean.pre-3 filtered.word_level.mean.pre-3-edge filtered.word_level.mean.post-3 filtered.word_level.mean.post-3-edge > \
    results.compare_smoothness.sample1.csv

# trained on filtered data, MEAN method, word level, compare smoothness, sample2

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.pre-3/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.pre-3-edge/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.post-3/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.post-3-edge/sample2 \
    --weights-names filtered.word_level.mean filtered.word_level.mean.pre-3 filtered.word_level.mean.pre-3-edge filtered.word_level.mean.post-3 filtered.word_level.mean.post-3-edge > \
    results.compare_smoothness.sample2.csv

# trained on filtered data, word level, compare mean and geomean

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.smooth/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean.smooth/sample2 \
    --weights-names filtered.word_level.mean filtered.word_level.mean.smooth filtered.word_level.geomean filtered.word_level.geomean.smooth > \
    results.compare_mean_geomean.sample2.csv

