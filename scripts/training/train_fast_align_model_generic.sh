#!/bin/bash

# calling script needs to set:

# $base
# $fast_align_sub
# $reverse_option

base=$1
fast_align_sub=$2
reverse_option=$3


OMP_NUM_THREADS=16 $base/tools/fast_align/build/fast_align \
    -i $fast_align_sub/input \
    -d -v -o $reverse_option \
    -p $fast_align_sub/params.out \
    > $fast_align_sub/alignments \
    2> $fast_align_sub/params.err
