#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

src=de
trg=en

data=$base/data

alignments=$base/alignments

for model_name in raw_paracrawl.100.filtered; do

   data_sub=$data/$model_name
   alignments_sub=$alignments/$model_name

   python $base/scripts/fast_align/weights_from_alignments.py \
       --alignments $alignments_sub/output \
       --weights $alignments_sub/weights \
       --source $data_sub/train.bpe.$src \
       --target $data_sub/train.bpe.$trg

done
