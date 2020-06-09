#! /bin/bash

# calling process needs to set

# $data
# $model_name
# $origin_sub
# $src
# $trg

echo "model_name: $model_name"

baseline_sub=$data/baseline
data_sub=$data/$model_name

mkdir -p $data_sub

# concat training data

for lang in $src $trg; do
  cat $baseline_sub/train.bpe.$lang $origin_sub/train.bpe.$lang > $data_sub/train.bpe.$lang
done

# link dev and test sets

for corpus in dev test test_ood; do
  ln -snf $baseline_sub/$corpus.bpe.$src $data_sub/$corpus.bpe.$src
  ln -snf $baseline_sub/$corpus.bpe.$trg $data_sub/$corpus.bpe.$trg
done
