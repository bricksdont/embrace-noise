#! /bin/bash

# calling script has to set:

# $base
# $noise_type

scripts=$base/scripts

src=de
trg=en

#################

echo "noise_type: $noise_type"

data=$base/data

sub_data=$data/train/$noise_type

mkdir -p $sub_data

# concatenate different amounts of noise

for amount in 05 10 20 50 100; do
  for lang in $src $trg; do
    cat $data/train/raw/baseline.tok.$lang $data/train/raw/$noise_type.$amount.tok.$lang > $sub_data/train.$amount.tok.$lang
  done
done

# sizes
echo "Sizes of all files:"

wc -l $sub_data/*

# sanity checks
echo "At this point, please make sure that 1) number of lines are as expected, 2) language suffixes are correct and 3) files are parallel"
