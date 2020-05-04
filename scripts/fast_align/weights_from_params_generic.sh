#! /bin/bash

# calling process needs to set:
# $base
# $fast_align_sub
# $alignments_sub
# $data_sub
base=$1
fast_align_sub=$2
alignments_sub=$3
data_sub=$4

src=de
trg=en

python $base/scripts/fast_align/weights_from_params.py \
   --params $fast_align_sub/params.out \
   --weights $alignments_sub/weights \
   --source $data_sub/train.bpe.$src \
   --target $data_sub/train.bpe.$trg
