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

  if [[ -f $chunk_output_dir/$chunk_prefix"$chunk_index" ]]; then

      num_lines_input_chunk=`wc -l $chunk_input_dir/$chunk_prefix"$chunk_index"`
      num_lines_output_chunk=`wc -l $chunk_output_dir/$chunk_prefix"$chunk_index"`

      echo "num_lines_input_chunk: $num_lines_input_chunk"
      echo "num_lines_output_chunk: $num_lines_output_chunk"

      exit

      if [[ $num_lines_input_chunk == $num_lines_output_chunk ]]; then
          echo "output chunk exists and number of lines are equal to input chunk:"
          echo "$num_lines_input_chunk == $num_lines_output_chunk"
          echo "Skipping."
          continue
      fi
  fi

	sbatch --qos=vesta --time=00:30:00 --gres gpu:Tesla-V100:1 --cpus-per-task 3 --mem 48g $scripts/translation/decode_chunk.sh \
            $chunk_input_dir $chunk_output_dir $chunk_prefix $chunk_index $model_path $batch_size
done

# query queue to see if finished
# note: this might not work if you have other unrelated tasks in the queue

while [[ `squeue -u mathmu -o "%.45j" | grep "chunk" | wc -l` != 0  ]];  do
    echo "Waiting for chunk decoding to finish, sleep 1000"
    sleep 1000
done

# move logs out of the way

mv $chunk_output_dir/*.log $chunk_log_dir/

# concatenating results

cat $chunk_output_dir/$chunk_prefix* > $distill_sub/train.bpe.$trg

