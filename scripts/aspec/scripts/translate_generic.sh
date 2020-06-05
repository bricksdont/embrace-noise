#! /bin/bash

# calling script needs to set:

# $base
# $data_sub
# $translations_sub
# $model_path
# $src
# $trg

base=$1
data_sub=$2
translations_sub=$3
model_path=$4
src=$5
trg=$6

num_threads=1
device_arg="--device-ids 0"

for corpus in dev test; do

    if [[ -s $translations_sub/$corpus.pieces.$trg ]]; then
      echo "File exists: $translations_sub/$corpus.pieces.$trg"
      echo "Skipping"
      continue
    fi

    # produce nbest list, desired beam size, desired batch size

    # 1-best, fixed beam size, fixed batch size

    OMP_NUM_THREADS=$num_threads python -m sockeye.translate \
            -i $data_sub/$corpus.pieces.$src \
            -o $translations_sub/$corpus.pieces.$trg \
            -m $model_path \
            --beam-size 10 \
            --length-penalty-alpha 1.0 \
            $device_arg \
            --batch-size 64 \
            --disable-device-locking

    # undo pieces

    cat $translations_sub/$corpus.pieces.$trg | \
        python $base/scripts/aspec/scripts/remove_sentencepiece.py --model $base/shared_models/baseline/$src$trg.sentencepiece.model \
            > $translations_sub/$corpus.$trg

done
