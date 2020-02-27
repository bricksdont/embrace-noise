#! /bin/bash

# calling process needs to set

# $LASER
# $raw_src
# $raw_trg
# $src
# $trg
# $embeddings_src
# $embeddings_trg
# $mined_file
# $mining_threshold
# $device_arg
# $mining_method

LASER=$1
raw_src=$2
raw_trg=$3
src=$4
trg=$5
embeddings_src=$6
embeddings_trg=$7
mined_file=$8
mining_threshold=$9
device_arg=${10}
mining_method=${11}

export LASER=$LASER

log_file=$mined_file.log

python ${LASER}/source/mine_bitexts.py \
          ${raw_src} \
          ${raw_trg} \
          --src-lang ${src} --trg-lang ${trg} \
          --src-embeddings ${embeddings_src} \
          --trg-embeddings ${embeddings_trg} \
          --unify --mode ${mining_method} --retrieval max --margin ratio -k 4  \
          --output ${mined_file} --threshold ${mining_threshold} \
          --verbose ${device_arg} 2>&1 | tee -a $log_file

# reverse numerical sort

cat $mined_file | sort -rn > $mined_file.sorted
