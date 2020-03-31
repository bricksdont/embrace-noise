#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

src=de
trg=en

data=$base/data

data_sub=$data/baseline

fast_align=$base/fast_align

mkdir -p $fast_align

# forward model

fast_align_sub=$fast_align/baseline

mkdir -p $fast_align_sub

perl $base/tools/paste-files.pl $data_sub/train.bpe.$src $data_sub/train.bpe.$trg > $fast_align_sub/input

sbatch --cpus-per-task=16 --time=24:00:00 --mem=16G --partition=hydra $base/scripts/training/train_fast_align_model_generic.sh $base $fast_align_sub ""

# reverse model

fast_align_sub=$fast_align/baseline_reverse

mkdir -p $fast_align_sub

perl $base/tools/paste-files.pl $data_sub/train.bpe.$src $data_sub/train.bpe.$trg > $fast_align_sub/input

sbatch --cpus-per-task=16 --time=24:00:00 --mem=16G --partition=hydra $base/scripts/training/train_fast_align_model_generic.sh $base $fast_align_sub "-r"
