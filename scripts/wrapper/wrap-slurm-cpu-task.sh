#!/bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

sbatch --cpus-per-task=16 --time=12:00:00 --mem=64G --partition=hydra $1 mode=sbatch
