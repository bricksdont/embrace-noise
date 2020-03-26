#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate

src=de
trg=en

data=$base/data
translations=$base/translations
evaluations=$base/evaluation

mkdir -p $evaluations

for translations_sub in $translations/*; do

    echo "translations_sub: $translations_sub"

    name=$(basename $translations_sub)

    data_sub=$data/$name
    evaluations_sub=$evaluations/$name

    #if [[ -d $evaluations_sub ]]; then
    #    echo "Folder exists: $evaluations_sub"
    #    echo "Skipping."
    #    continue
    #fi

    mkdir -p $evaluations_sub

    . $base/scripts/evaluation/evaluate_generic.sh

done
