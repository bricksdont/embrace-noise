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

for model_name in raw_paracrawl.100.filtered; do

   data_sub=$data/$model_name
   fast_align_sub=$fast_align/$model_name

   python $base/scripts/fast_align/weights_from_params.py \
       --params $fast_align_sub/params.out \
       --weights $alignments_sub/weights \
       --source $data_sub/train.bpe.$src \
       --target $data_sub/train.bpe.$trg

done
