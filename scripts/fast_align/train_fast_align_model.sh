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

if [[ ! -s $fast_align_sub/input.raw ]]; then
    perl $base/tools/paste-files.pl $data_sub/train.bpe.$src $data_sub/train.bpe.$trg > $fast_align_sub/input.raw
fi

if [[ ! -s $fast_align_sub/input ]]; then
    perl $base/tools/filter-length.pl -200 $fast_align_sub/input.raw > $fast_align_sub/input
fi

sbatch --cpus-per-task=16 --time=02:00:00 --mem=16G --partition=hydra $base/scripts/fast_align/train_fast_align_model_generic.sh $base $fast_align_sub ""

# reverse model

fast_align_sub=$fast_align/baseline_reverse

mkdir -p $fast_align_sub

ln -snf $fast_align/baseline/input $fast_align/baseline_reverse/input

sbatch --cpus-per-task=16 --time=02:00:00 --mem=16G --partition=hydra $base/scripts/fast_align/train_fast_align_model_generic.sh $base $fast_align_sub "-r"
