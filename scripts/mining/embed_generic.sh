#! /bin/bash

# calling process needs to set

# $LASER
# $encoder
# $bpe_codes
# $raw_file
# $embedded_file
# $language

LASER=$1
encoder=$2
bpe_codes=$3
raw_file=$4
embedded_file=$5
language=$6

export LASER=$LASER

log_file=$embedded_file.log

echo "Embedding: $raw_file"

cat ${raw_file} | python ${LASER}/source/embed.py \
      --encoder ${encoder} \
      --bpe-codes ${bpe_codes} \
      --output ${embedded_file} \
      --token-lang ${language} \
      --verbose 2>&1 | tee -a $log_file
