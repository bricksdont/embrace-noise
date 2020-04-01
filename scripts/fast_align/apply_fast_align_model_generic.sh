#!/bin/bash

# calling script needs to set:

# $base
# $alignments_sub
# $fast_align_sub_forward
# $fast_align_sub_reverse

base=$1
alignments_sub=$2
fast_align_sub_forward=$3
fast_align_sub_reverse=$4

python2 $base/tools/fast_align/build/force_align.py \
    $fast_align_sub_forward/params.out \
    $fast_align_sub_forward/params.err \
    $fast_align_sub_reverse/params.out \
    $fast_align_sub_reverse/params.err \
    grow-diag-final-and \
    < $alignments_sub/input \
    > $alignments_sub/output
