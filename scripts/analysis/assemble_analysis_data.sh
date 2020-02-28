#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

analysis=$base/analysis
data=$base/data
filtered=$base/filtered

mkdir -p $analysis

src=de
trg=en

paste $filtered/raw_paracrawl.100/train.$src $filtered/raw_paracrawl.100/train.$trg > $analysis/filtered

# baseline number of lines: 3520019

offset=3520019

for method in adq adq-dom; do
    for fraction in 0.25 0.5 0.75; do
        paste $data/raw_paracrawl.100.dcce.$method.$fraction/train.bpe.$src $data/raw_paracrawl.100.dcce.$method.$fraction/train.bpe.$trg > $analysis/dcce.$method.$fraction.all

        sed -n "$offset,$ p" $analysis/dcce.$method.$fraction.all > $analysis/dcce.$method.$fraction
    done
done

for method in mine score; do
    for fraction in 0.25 0.5 0.75; do
        paste $data/raw_paracrawl.100.mined.$method.$fraction/train.bpe.$src $data/raw_paracrawl.100.mined.$method.$fraction/train.bpe.$trg > $analysis/mined.$method.$fraction.all

        sed -n "$offset,$ p" $analysis/mined.$method.$fraction.all > $analysis/mined.$method.$fraction
    done
done
