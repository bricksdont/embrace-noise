#! /bin/bash

chunk_input_dir=$1
chunk_output_dir=$2
chunk_prefix=$3
chunk_index=$4

model_paths=$5
batch_size=$6

OMP_NUM_THREADS=3 python -m sockeye.translate \
            -i $chunk_input_dir/$chunk_prefix"$chunk_index" \
            -o $chunk_output_dir/$chunk_prefix"$chunk_index" \
            -m $model_paths \
            --beam-size 10 \
            --length-penalty-alpha 1.0 \
            --device-ids 0 \
            --batch-size $batch_size \
            --disable-device-locking
