#!/bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra


# new
sbatch -A T2-CS037-GPU --gres=gpu:1 --nodes=1 --time=36:00:00 --cpus-per-task 3 \
       -p pascal $1 mode=sbatch
