#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate

src=de
trg=en

data=$base/data
translations=$base/translations
evaluations=$base/evaluation

mkdir -p $evaluations

# custom eval for baseline

data_sub=$data/baseline
translations_sub=$translations/baseline
evaluations_sub=$evaluations/baseline

mkdir -p $evaluations_sub

. $base/scripts/evaluation/evaluate_generic.sh

# custom eval for baseline_distilled

data_sub=$data/baseline_distilled
translations_sub=$translations/baseline_distilled
evaluations_sub=$evaluations/baseline_distilled

mkdir -p $evaluations_sub

. $base/scripts/evaluation/evaluate_generic.sh

for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg untranslated_de_trg_distilled short_max2 short_max5 raw_paracrawl raw_paracrawl_distilled; do
  for noise_amount in 05 10 20 50 100; do

    echo "noise_type: $noise_type"
    echo "noise_amount: $noise_amount"

    data_sub=$data/$noise_type.$noise_amount
    translations_sub=$translations/$noise_type.$noise_amount

    if [[ ! -d $translations_sub ]]; then
        echo "Folder does not exist: $translations_sub"
        echo "Skipping."
        continue
    fi

    evaluations_sub=$evaluations/$noise_type.$noise_amount

    mkdir -p $evaluations_sub

    . $base/scripts/evaluation/evaluate_generic.sh

  done
done

