#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

src=de
trg=en

scripts=$base/scripts
preprocessed=$base/preprocessed
filtered=$base/filtered
tools=$base/tools

mkdir -p $filtered

# filter baseline

preprocessed_sub=$preprocessed/baseline
filter_sub=$filtered/baseline

mkdir -p $filter_sub

input_src=$preprocessed_sub/train.bpe.$src
input_trg=$preprocessed_sub/train.bpe.$trg

output_src=$filter_sub/train.bpe.$src
output_trg=$filter_sub/train.bpe.$trg

logfile=$filter_sub/log

. $scripts/preprocessing/filter_generic.sh 2>&1 | tee -a $logfile


# noise data sets (noise only, not combined with baseline data)

# for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do

for noise_type in raw_paracrawl; do
  for noise_amount in 05 10 20 50 100; do

    echo "noise_type: $noise_type"
    echo "noise_amount: $noise_amount"

    preprocessed_sub=$preprocessed/$noise_type.$noise_amount
    filter_sub=$filtered/$noise_type.$noise_amount

    if [[ -d $filter_sub ]]; then
        echo "Folder exists: $filter_sub"
        echo "Skipping."
        continue
    fi

    mkdir -p $filter_sub

    input_src=$preprocessed_sub/train.bpe.$src
    input_trg=$preprocessed_sub/train.bpe.$trg

    output_src=$filter_sub/train.bpe.$src
    output_trg=$filter_sub/train.bpe.$trg

    logfile=$filter_sub/log

    . $scripts/preprocessing/filter_generic.sh 2>&1 | tee -a $logfile

  done
done

echo "Size of all files:"
wc -l $filtered/*/*
