#! /bin/bash

source /net/cephfs/home/mathmu/scratch/goeckeritz-model/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

base=/net/cephfs/home/mathmu/scratch/goeckeritz-model

# vars set by calling process:

# corpus
# model_name
# model_paths
# batch_size
# chunk_size

data=$base/data
scripts=$base/scripts

translations=$base/translations

src=en
trg=de

mkdir -p $translations
mkdir -p $translations/$model_name

chunk_prefix="$corpus.bpe.$model_name.chunk."
chunk_input_dir=$translations/$model_name/chunk_inputs
chunk_output_dir=$translations/$model_name/chunk_outputs

mkdir -p $chunk_input_dir
mkdir -p $chunk_output_dir

# splitting input file into chunks

zless $data/$corpus.$src | split -d -l $chunk_size -a 3 - $chunk_input_dir/$chunk_prefix

# get number of chunk files generated

num_chunks=`ls $chunk_input_dir | wc -l`

echo "Number of chunks found: $num_chunks"

# translating individual chunks

for chunk_index in $(seq -f "%03g" 0 $(($num_chunks - 1))); do
	sbatch --qos=vesta --time=1:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 3 --mem 48g $scripts/decode_chunk.sh \
            $chunk_input_dir $chunk_output_dir $chunk_prefix $chunk_index $model_paths $batch_size
done

# concatenating results

while [[ `squeue -u mathmu | wc -l` != 1  ]];  do
	sleep 1000
done

# not possible currently since we do not query the queue to see if translations are finished

cat $chunk_output_dir/$chunk_prefix* > $translations/$model_name/$corpus.bpe.$model_name.$trg

