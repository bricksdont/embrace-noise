#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

src=de
trg=en

scripts=$base/scripts
data=$base/data
filtered=$base/filtered
tools=$base/tools

mkdir -p $filtered

# filter baseline

data_sub=$data/baseline_distilled
filter_sub=$distilled/baseline_distilled

mkdir -p $filter_sub

input_src=$data_sub/train.bpe.$src
input_trg=$data_sub/train.bpe.$trg

output_src=$filter_sub/train.bpe.$src
output_trg=$filter_sub/train.bpe.$trg

. $scripts/preprocessing/filter_generic.sh


# baseline data combined with noise

for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do
  for noise_amount in 05 10 20 50 100; do

    echo "noise_type: $noise_type"
    echo "noise_amount: $noise_amount"

    distill_sub=$distilled/$noise_type.$noise_amount
    data_sub=$data/$noise_type"_distilled".$noise_amount

    if [[ -d $filter_sub ]]; then
        echo "Folder exists: $data_sub"
        echo "Skipping."
        continue
    fi

    mkdir -p $filter_sub

    input_src=$data_sub/train.bpe.$src
    input_trg=$data_sub/train.bpe.$trg

    output_src=$filter_sub/train.bpe.$src
    output_trg=$filter_sub/train.bpe.$trg

    . $scripts/preprocessing/filter_generic.sh

    done

  done
done
