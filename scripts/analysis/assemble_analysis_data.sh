#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

analysis=$base/analysis
data=$base/data
filtered=$base/filtered
mined=$base/mined
scripts=$base/scripts

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

# raw without preprocessing to compare against filtered

analysis_sub=$analysis/mined_raw

mkdir -p $analysis_sub

# total lines in filtered

num_lines=2069323

for method in mine score; do

    cut -f2,3 $mined/raw_paracrawl.100/mined.$method.sorted > $analysis_sub/mined.$method.100

    for fraction in 0.25 0.5 0.75; do
        cat $analysis_sub/mined.$method.100 | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines > $analysis_sub/mined.$method.$fraction
    done
done

# with preprocessing to compare against DCCE

analysis_sub=$analysis/mined_bpe

mkdir -p $analysis_sub

for method in mine score; do
    for fraction in 0.25 0.5 0.75; do
      paste $data/raw_paracrawl.100.mined.$method.$fraction/train.bpe.$src $data/raw_paracrawl.100.mined.$method.$fraction/train.bpe.$trg > $analysis_sub/mined.$method.$fraction.all

      sed -n "$offset,$ p" $analysis_sub/mined.$method.$fraction.all > $analysis_sub/mined.$method.$fraction
    done
done

wc -l $analysis/* $analysis/*/*
