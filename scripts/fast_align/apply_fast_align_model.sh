#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

src=de
trg=en

data=$base/data

fast_align=$base/fast_align

alignments=$base/alignments

mkdir -p $alignments

for model_name in raw_paracrawl.100.filtered; do

   data_sub=$data/$model_name
   alignments_sub=$alignments/$model_name

   fast_align_sub_forward=$fast_align/baseline
   fast_align_sub_reverse=$fast_align/baseline_reverse

   if [[ ! -s $alignments_sub/input ]]; then
    perl $base/tools/paste-files.pl $data_sub/train.bpe.$src $data_sub/train.bpe.$trg > $alignments_sub/input
fi

   sbatch --cpus-per-task=16 --time=02:00:00 --mem=16G --partition=hydra $base/scripts/fast_align/apply_fast_align_model_generic.sh $base $alignments_sub $fast_align_sub_forward $fast_align_sub_reverse

done
