#! /bin/bash

# work around slurm placing scripts in var folder
if [[ $1 == "mode=sbatch" ]]; then
  base=/net/cephfs/home/mathmu/scratch/noise-distill
else
  script_dir=`dirname "$0"`
  base=$script_dir/../..
fi;

MOSES=$base/tools/moses-scripts/scripts

bpe_total_symbols=32000
bpe_vocab_threshold=50

shared_models=$base/shared_models

mkdir -p $shared_models

# normalization and tokenization of dev and test, only do that once

# normalize dev and test

for corpus in dev test; do
  cat $data/raw/$corpus/$corpus.$src | perl $MOSES/tokenizer/normalize-punctuation.perl > $data/raw/$corpus/$corpus.normalized.$src
  cat $data/raw/$corpus/$corpus.$trg | perl $MOSES/tokenizer/normalize-punctuation.perl > $data/raw/$corpus/$corpus.normalized.$trg
done

# tokenize dev and test

for corpus in dev test; do
  cat $data/raw/$corpus/$corpus.normalized.$src | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $src > $data/raw/$corpus/$corpus.tok.$src
  cat $data/raw/$corpus/$corpus.normalized.$trg | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $trg > $data/raw/$corpus/$corpus.tok.$trg
done

# individual training data + BPE model for each experiment

for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do
    for noise_amount in 05 10 20 50 100; do

      echo "noise_type: $noise_type"
      echo "noise_amount: $noise_amount"

      # folder for preprocessed data

      data_sub=$data/$noise_type.$noise_amount
      mkdir -p $data_sub

      # concatenate training data

      for lang in $src $trg; do
        cat $data/raw/train/baseline.tok.$lang $data/raw/train/$noise_type.$noise_amount.tok.$lang > $data_sub/train.tok.$lang
      done

      # link dev and test tokenized files
      for corpus in dev test; do
        ln -s $data/raw/$corpus/$corpus.tok.$src $data/baseline/$corpus.tok.$src
        ln -s $data/raw/$corpus/$corpus.tok.$trg $data/baseline/$corpus.tok.$trg
      done

      # folder for BPE model

      shared_models_sub=$shared_models/$noise_type.$noise_amount
      mkdir -p $shared_models_sub

    . $base/scripts/preprocessing/preprocess_generic.sh
    done
done

# one more call for baseline without noise

data_sub=$data/baseline
mkdir -p $data_sub

# link data sets (no need to concat for baseline)

ln -s $data/raw/train/baseline.tok.$src $data_sub/train.$src
ln -s $data/raw/train/baseline.tok.$trg $data_sub/train.$trg

for corpus in dev test; do
  ln -s $data/raw/$corpus/$corpus.tok.$src $data_sub/$corpus.tok.$src
  ln -s $data/raw/$corpus/$corpus.tok.$trg $data_sub/$corpus.tok.$trg
done

shared_models_sub=$shared_models/baseline
mkdir -p $shared_models_sub

. $base/scripts/preprocessing/preprocess_generic.sh
