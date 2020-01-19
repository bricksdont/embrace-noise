#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

src=de
trg=en

data=$base/data
translations=$base/translations
evaluations=$base/evaluation

mkdir -p $evaluations

# custom eval for baseline

data_sub=$data/baseline
translations_sub=$translations/baseline
evaluations_sub=$evaluation/baseline

mkdir -p $evaluations_sub

. $base/scripts/evaluation/evaluate_generic.sh

for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do
  for noise_amount in 05 10 20 50 100; do

    echo "noise_type: $noise_type"
    echo "noise_amount: $noise_amount"

    data_sub=$data/$noise_type.$noise_amount
    translations_sub=$translations/$noise_type.$noise_amount
    evaluations_sub=$evaluations/$noise_type.$noise_amount

    if [[ -d $evaluations_sub ]]; then
        echo "Folder exists: $evaluations_sub"
        echo "Skipping."
        continue
    fi

    mkdir -p $evaluations_sub

    . $base/scripts/evaluation/evaluate_generic.sh

  done
done

