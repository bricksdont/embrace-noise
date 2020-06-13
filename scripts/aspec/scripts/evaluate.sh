#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/laser3/bin/activate

data=$base/data
translations=$base/translations
evaluations=$base/evaluation

mkdir -p $evaluations

for translations_sub in $translations/*; do

    name=$(basename $translations_sub)

    data_sub=$data/$name
    evaluations_sub=$evaluations/$name

    if [[ -d $evaluations_sub ]]; then
        # echo "Folder exists: $evaluations_sub"
        # echo "Skipping."
        continue
    fi

    echo "translations_sub: $translations_sub"

    mkdir -p $evaluations_sub

    if [[ $name == "baseline.reverse" ]]; then
      trg=en
    else
      trg=ja
    fi

    . $basebase/scripts/aspec/scripts/evaluate_generic.sh

done
