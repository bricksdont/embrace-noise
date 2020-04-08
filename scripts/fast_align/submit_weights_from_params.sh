#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra


sbatch --cpus-per-task=1 --time=02:00:00 --mem=4G --partition=hydra $base/scripts/fast_align/weights_from_params.sh
