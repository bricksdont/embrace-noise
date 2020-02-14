#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/laser3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0


scripts=$base/scripts

preprocessed_lm=$base/preprocessed_lm
models_lm=$base/models_lm

mkdir -p $models_lm

for preprocessed_lm_sub in $preprocessed_lm/*; do

  name=$(basename $preprocessed_lm_sub)

  echo "$name"

  models_lm_sub=$models_lm/$name

  if [[ -d $models_lm_sub ]]; then
      echo "Folder exists: $models_lm_sub"
      echo "Skipping."
      continue
  fi

  mkdir -p $models_lm_sub

  sbatch --qos=vesta --time=72:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 1 --mem 16g $scripts/training/train_lm_generic.sh $preprocessed_lm_sub $models_lm_sub

done
