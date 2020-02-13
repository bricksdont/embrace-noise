#! /bin/bash

# calling process needs to set:

# $input_src
# $input_trg
# $output
# $batch_size
# $model_path

input_src=$1
input_trg=$2
output=$3
batch_size=$4
model_path=$5

OMP_NUM_THREADS=1 python -m sockeye.score \
        --source $input_src \
        --target $input_trg \
        -m $model_path \
        --length-penalty-alpha 1.0 \
        --device-ids 0 \
        --batch-size $batch_size \
        --disable-device-locking \
        --max-seq-len 128:128 \
        --score-type logprob \
        --output $output
