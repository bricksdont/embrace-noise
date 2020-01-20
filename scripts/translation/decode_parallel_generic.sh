#! /bin/bash

# vars set by calling process:

# $src
# $trg
# $data_sub
# $distill_sub
# $model_path
# $batch_size
# $chunk_size

chunk_prefix="train.bpe.chunk."
chunk_input_dir=$distill_sub/chunk_inputs
chunk_output_dir=$distill_sub/chunk_outputs
chunk_log_dir=$distill_sub/chunk_logs

mkdir -p $chunk_input_dir
mkdir -p $chunk_output_dir
mkdir -p $chunk_log_dir

# splitting input file into chunks

zless $data_sub/train.bpe.$src | split -d -l $chunk_size -a 3 - $chunk_input_dir/$chunk_prefix

# get number of chunk files generated

num_chunks=`ls $chunk_input_dir | wc -l`

echo "Number of chunks found: $num_chunks"

# translating individual chunks

for chunk_index in $(seq -f "%03g" 0 $(($num_chunks - 1))); do
	sbatch --qos=vesta --time=1:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 3 --mem 48g $scripts/decode_chunk.sh \
            $chunk_input_dir $chunk_output_dir $chunk_prefix $chunk_index $model_path $batch_size
done

# query queue to see if finished
# note: this does not work if you have other unrelated tasks in the queue

while [[ `squeue -u mathmu | wc -l` != 1  ]];  do
    sleep 1000
done

# move logs out of the way

mv $chunk_output_dir/*.log $chunk_log_dir/

# concatenating results

cat $chunk_output_dir/$chunk_prefix* > $distill_sub//train.bpe.$trg

