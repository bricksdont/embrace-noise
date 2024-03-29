#! /bin/bash

# calling script has to set:

# $data_sub
# $shared_models_sub
# $bpe_vocab_threshold
# $bpe_total_symbols
# $src
# $trg

data_sub=$1
shared_models_sub=$2
bpe_vocab_threshold=$3
bpe_total_symbols=$4
src=$5
trg=$6

# measure time

SECONDS=0

#################

echo "data_sub: $data_sub"

# learn BPE model on train (concatenate both languages)

if [[ ! -f $shared_models_sub/$src$trg.bpe ]]; then

  subword-nmt learn-joint-bpe-and-vocab -i $data_sub/train.tok.$src $data_sub/train.tok.$trg \
    --write-vocabulary $shared_models_sub/vocab.$src $shared_models_sub/vocab.$trg \
    --total-symbols --symbols $bpe_total_symbols -o $shared_models_sub/$src$trg.bpe

else
  echo "BPE model exists: $shared_models_sub/$src$trg.bpe"
  echo "Skipping model training"
fi

# apply BPE model to train, test and dev

for corpus in train dev test; do
  subword-nmt apply-bpe -c $shared_models_sub/$src$trg.bpe \
      --vocabulary $shared_models_sub/vocab.$src \
      --vocabulary-threshold $bpe_vocab_threshold < $data_sub/$corpus.tok.$src > $data_sub/$corpus.bpe.$src

  subword-nmt apply-bpe -c $shared_models_sub/$src$trg.bpe \
      --vocabulary $shared_models_sub/vocab.$trg \
      --vocabulary-threshold $bpe_vocab_threshold < $data_sub/$corpus.tok.$trg > $data_sub/$corpus.bpe.$trg
done

# sizes
echo "Sizes of all files:"

wc -l $data_sub/*
wc -l $shared_models_sub/*

# sanity checks
echo "At this point, please make sure that 1) number of lines are as expected, 2) language suffixes are correct and 3) files are parallel"

echo "time taken:"
echo "$SECONDS seconds"
