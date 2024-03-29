#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

src=de
trg=en

data=$base/data
filtered=$base/filtered
shared_models=$base/shared_models

MOSES=$base/tools/moses-scripts/scripts

bpe_total_symbols=32000
bpe_vocab_threshold=50

preprocessed=$base/preprocessed

mkdir -p $shared_models $preprocessed

# normalization and tokenization of dev and test, only do that once

# normalize dev and test

for corpus in dev test; do
  cat $data/raw/$corpus/$corpus.$src | perl $MOSES/tokenizer/normalize-punctuation.perl $src > $data/raw/$corpus/$corpus.normalized.$src
  cat $data/raw/$corpus/$corpus.$trg | perl $MOSES/tokenizer/normalize-punctuation.perl $trg > $data/raw/$corpus/$corpus.normalized.$trg
done

# tokenize dev and test

for corpus in dev test; do
  cat $data/raw/$corpus/$corpus.normalized.$src | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $src > $data/raw/$corpus/$corpus.tok.$src
  cat $data/raw/$corpus/$corpus.normalized.$trg | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $trg > $data/raw/$corpus/$corpus.tok.$trg
done

# call for baseline without noise

data_sub=$preprocessed/baseline
mkdir -p $data_sub

# link data sets

ln -snf $data/raw/train/baseline.tok.$src $data_sub/train.tok.$src
ln -snf $data/raw/train/baseline.tok.$trg $data_sub/train.tok.$trg

for corpus in dev test; do
  ln -snf $data/raw/$corpus/$corpus.tok.$src $data_sub/$corpus.tok.$src
  ln -snf $data/raw/$corpus/$corpus.tok.$trg $data_sub/$corpus.tok.$trg
done

shared_models_sub=$shared_models/baseline
mkdir -p $shared_models_sub

sbatch --cpus-per-task=1 --time=00:30:00 --mem=4G --partition=hydra \
    $base/scripts/preprocessing/preprocess_generic.sh \
        $data_sub $shared_models_sub $bpe_vocab_threshold $bpe_total_symbols $src $trg

# individual training data for each experiment

# for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do
for noise_type in raw_paracrawl; do
    # for noise_amount in 05 10 20 50 100; do
    for noise_amount in 100; do

      echo "#######################################"

      echo "noise_type: $noise_type"
      echo "noise_amount: $noise_amount"

      # folder for preprocessed data

      data_sub=$preprocessed/$noise_type.$noise_amount

      if [[ -d $data_sub ]]; then
        echo "Folder exists: $data_sub"
        echo "Skipping."
        continue
      fi

      mkdir -p $data_sub

      # link training data

      for lang in $src $trg; do
        ln -snf $data/raw/train/$noise_type.$noise_amount.tok.$lang $data_sub/train.tok.$lang
      done

      # link dev and test tokenized files

      for corpus in dev test; do
        ln -snf $data/raw/$corpus/$corpus.tok.$src $data_sub/$corpus.tok.$src
        ln -snf $data/raw/$corpus/$corpus.tok.$trg $data_sub/$corpus.tok.$trg
      done

      # folder for BPE model: do NOT train new BPE models, always use baseline model

      shared_models_sub=$shared_models/baseline

      sbatch --cpus-per-task=1 --time=00:30:00 --mem=4G --partition=hydra \
          $base/scripts/preprocessing/preprocess_generic.sh \
              $data_sub $shared_models_sub $bpe_vocab_threshold $bpe_total_symbols $src $trg
    done
done

shopt -s nullglob

for filter_sub in $filtered/*; do

    echo "filter_sub: $filter_sub"

    # folder for preprocessed data

    data_sub=$filter_sub

    # link dev and test tokenized files

    for corpus in dev test; do
      ln -snf $data/raw/$corpus/$corpus.tok.$src $data_sub/$corpus.tok.$src
      ln -snf $data/raw/$corpus/$corpus.tok.$trg $data_sub/$corpus.tok.$trg
    done

    if [[ -f $data_sub/$corpus.bpe.$src ]]; then
        echo "File exists: $data_sub/$corpus.bpe.$src"
        echo "Skipping."
        continue
    fi

    # folder for BPE model: do NOT train new BPE models, always use baseline model

    shared_models_sub=$shared_models/baseline

    sbatch --cpus-per-task=1 --time=00:30:00 --mem=4G --partition=hydra \
        $base/scripts/preprocessing/preprocess_generic.sh \
            $data_sub $shared_models_sub $bpe_vocab_threshold $bpe_total_symbols $src $trg
done
