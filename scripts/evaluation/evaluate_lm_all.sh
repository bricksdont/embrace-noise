#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/fairseq3/bin/activate

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

    sbatch --qos=vesta --time=00:30:00 --gres gpu:Tesla-V100:1 --cpus-per-task 1 --mem 16g $base/scripts/evaluation/evaluate_lm_generic.sh $evaluations_lm_sub $preprocessed_lm_sub $models_lm_sub

done
