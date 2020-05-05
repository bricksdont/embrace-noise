#! /bin/bash

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
    --weights-names baseline.ignore baseline.only baseline.mean baseline.min baseline.max \
                    all.ignore all.only all.mean all.min all.max \
                    filtered.ignore filtered.only filtered.mean filtered.min filtered.max > \
    results.all.csv
