#! /bin/bash

# all sample 1

python3 display.py --source train.bpe.sample.de --target train.bpe.sample.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.ignore/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.only/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.min/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.geomean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean.geomean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max.geomean/sample \
    --weights-names filtered.word_level.ignore filtered.word_level.only filtered.word_level.mean filtered.word_level.min filtered.word_level.max filtered.word_level.geomean \
        filtered.word_level.mean.mean filtered.word_level.geomean.mean filtered.word_level.max.mean \
        filtered.word_level.mean.geomean filtered.word_level.geomean.geomean filtered.word_level.max.geomean > \
    results.all.sample1.csv

# all sample 2

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.ignore/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.only/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.min/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.geomean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean.geomean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max.geomean/sample2 \
    --weights-names filtered.word_level.ignore filtered.word_level.only filtered.word_level.mean filtered.word_level.min filtered.word_level.max filtered.word_level.geomean \
        filtered.word_level.mean.mean filtered.word_level.geomean.mean filtered.word_level.max.mean \
        filtered.word_level.mean.geomean filtered.word_level.geomean.geomean filtered.word_level.max.geomean > \
    results.all.sample2.csv

# trained on filtered data, word level, compare combination methods, sample 1

python3 display.py --source train.bpe.sample.de --target train.bpe.sample.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.ignore/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.only/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.min/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean/sample \
    --weights-names filtered.word_level.ignore filtered.word_level.only filtered.word_level.mean filtered.word_level.min filtered.word_level.max filtered.word_level.geomean > \
    results.compare_combination_methods.sample1.csv

# trained on filtered data, word level, compare combination methods, sample 2

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.ignore/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.only/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.min/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean/sample2 \
    --weights-names filtered.word_level.ignore filtered.word_level.only filtered.word_level.mean filtered.word_level.min filtered.word_level.max filtered.word_level.geomean > \
    results.compare_combination_methods.sample2.csv

# trained on filtered data, MEAN method, word level, compare smoothing method, sample 1

python3 display.py --source train.bpe.sample.de --target train.bpe.sample.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max.geomean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.geomean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean.mean/sample \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean.geomean/sample \
    --weights-names filtered.word_level.mean filtered.word_level.geomean \
                    filtered.word_level.max.mean filtered.word_level.max.geomean \
                    filtered.word_level.mean.mean filtered.word_level.mean.geomean \
                    filtered.word_level.geomean.mean filtered.word_level.geomean.geomean > \
    results.compare_smoothness.sample1.csv

# trained on filtered data, MEAN method, word level, compare smoothing method, sample 2

python3 display.py --source train.bpe.sample2.de --target train.bpe.sample2.en \
    --weights raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.max.geomean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.mean.geomean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean.mean/sample2 \
              raw_paracrawl.100.filtered.raw_paracrawl.100.filtered.word_level.geomean.geomean/sample2 \
     --weights-names filtered.word_level.mean filtered.word_level.geomean \
                    filtered.word_level.max.mean filtered.word_level.max.geomean \
                    filtered.word_level.mean.mean filtered.word_level.mean.geomean \
                    filtered.word_level.geomean.mean filtered.word_level.geomean.geomean > \
    results.compare_smoothness.sample2.csv

