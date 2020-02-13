#! /bin/bash

# this code is adapted from:
# https://github.com/facebookresearch/LASER/blob/master/tasks/bucc/bucc.sh

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/laser3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

src=de
trg=en

tools=$base/tools
data=$base/data
scripts=$base/scripts

LASER=$tools/laser

embedded=$base/embedded
filtered=$base/filtered
mined=$base/mined

mkdir -p $mined

# FAISS on GPU

device_arg="--gpu"

# no threshold, extract scores for all pairs

mining_threshold=0.0

for embedded_sub in $embedded/*; do

    echo "embedded_sub: $embedded_sub"

    name=$(basename $embedded_sub)

    filtered_sub=$filtered/$name
    mined_sub=$mined/$name

    mined_file=$mined_sub/mined

    if [[ -f $mined_file ]] ; then
      echo "File exists: $mined_sub"
      echo "Skipping."
      continue
    fi

    mkdir -p $mined_sub

    raw_src=$filtered_sub/train.$src
    raw_trg=$filtered_sub/train.$trg

    embeddings_src=$embedded_sub/train.embedded.$src
    embeddings_trg=$embedded_sub/train.embedded.$trg

    sbatch --qos=vesta --time=12:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 1 --mem 16g $scripts/mining/mine_generic.sh $LASER $raw_src \
      $raw_trg $src $trg $embeddings_src $embeddings_trg $mined_file $mining_threshold $device_arg

done