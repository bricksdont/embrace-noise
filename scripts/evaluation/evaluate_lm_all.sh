#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/laser3/bin/activate

models_lm=$base/models_lm
preprocessed_lm=$base/preprocessed_lm
evaluations_lm=$base/evaluations_lm

mkdir -p $evaluations_lm

for models_lm_sub in $models_lm/*; do

    echo "models_lm_sub: $models_lm_sub"

    name=$(basename $models_lm_sub)

    preprocessed_lm_sub=$preprocessed_lm/$name
    evaluations_lm_sub=$evaluations_lm/$name

    if [[ -d $evaluations_lm_sub ]]; then
        echo "Folder exists: $evaluations_sub"
        echo "Skipping."
        continue
    fi

    mkdir -p $evaluations_lm_sub

    . $base/scripts/evaluation/evaluate_lm_generic.sh

done
