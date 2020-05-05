#! /bin/bash

# calling process needs to set:
# $base
# $fast_align_sub
# $alignments_sub
# $data_sub
# $fast_align_sub_reverse
# $use_reverse_method
# $word_level_arg ("--word-level" or "")

base=$1
fast_align_sub=$2
alignments_sub=$3
data_sub=$4
fast_align_sub_reverse=$5
use_reverse_method=$6
word_level_arg=$7

src=de
trg=en

# TODO uncomment

#python $base/scripts/fast_align/weights_from_params.py \
#   --params $fast_align_sub/params.out \
#   --params-reverse $fast_align_sub_reverse/params.out \
#   --use-reverse-method $use_reverse_method \
#   --weights $alignments_sub/weights \
#   --source $data_sub/train.bpe.$src \
#   --target $data_sub/train.bpe.$trg $word_level_arg

# for now, sample only

python $base/scripts/fast_align/weights_from_params.py \
   --params $fast_align_sub/params.out \
   --params-reverse $fast_align_sub_reverse/params.out \
   --use-reverse-method $use_reverse_method \
   --weights $alignments_sub/sample \
   --source $data_sub/train.bpe.sample.$src \
   --target $data_sub/train.bpe.sample.$trg $word_level_arg
