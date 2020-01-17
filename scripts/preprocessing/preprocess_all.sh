#! /bin/bash

# work around slurm placing scripts in var folder
if [[ $1 == "mode=sbatch" ]]; then
  base=/net/cephfs/home/mathmu/scratch/noise-distill
else
  script_dir=`dirname "$0"`
  base=$script_dir/..
fi;

. $base/scripts/preprocessing/preprocess_generic.sh
