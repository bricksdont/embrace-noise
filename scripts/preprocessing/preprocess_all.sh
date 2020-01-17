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
  cat $data/$corpus/$corpus.$src | perl $MOSES/tokenizer/normalize-punctuation.perl > $data/$corpus/$corpus.normalized.$src
  cat $data/$corpus/$corpus.$trg | perl $MOSES/tokenizer/normalize-punctuation.perl > $data/$corpus/$corpus.normalized.$trg
done

# tokenize dev and test

for corpus in dev test; do
  cat $data/$corpus/$corpus.normalized.$src | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $src > $data/$corpus/$corpus.tok.$src
  cat $data/$corpus/$corpus.normalized.$trg | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $trg > $data/$corpus/$corpus.tok.$trg
done

# individual training data + BPE model for each experiment

for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do
    for noise_amount in 05 10 20 50 100; do

      for corpus in train dev test; do
        mkdir -p $data/$corpus/$noise_type.$noise_amount
      done

      # link dev and test tokenized files
      for corpus in dev test; do
        ln -s $data/$corpus/$corpus.tok.$src $data/$corpus/$noise_type.$noise_amount/$corpus.tok.$src
      done

      shared_models_individual=$shared_models/$noise_type
      mkdir -p $shared_models_individual

      for lang in $src $trg; do
        cat $data/train/raw/baseline.tok.$lang $data/train/raw/$noise_type.$noise_amount.tok.$lang > $sub_data/train.$noise_amount.tok.$lang
      done

      train_src=
      train_trg=

    . $base/scripts/preprocessing/preprocess_generic.sh
    done
done

# one more call for baseline without noise

for corpus in dev test train; do
  mkdir -p $data/$corpus/baseline
done

ln -s $data/train/raw/baseline.tok.$src $data/train/baseline/train.$src
ln -s $data/train/raw/baseline.tok.$src $data/train/baseline/train.$trg

ln -s $data/dev/

shared_models_individual=$shared_models/baseline
mkdir -p $shared_models_individual

. $base/scripts/preprocessing/preprocess_generic.sh
