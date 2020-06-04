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

scripts=$base/scripts
MOSES=$base/tools/moses-scripts/scripts

num_threads=3
device_arg="--device-ids 0"

for corpus in dev test; do

    # produce nbest list, desired beam size, desired batch size

    # 1-best, fixed beam size, fixed batch size

    OMP_NUM_THREADS=$num_threads python -m sockeye.translate \
            -i $data_sub/$corpus.tag.$src \
            -o $translations_sub/$corpus.tag.$trg \
            -m $model_path \
            --beam-size 10 \
            --length-penalty-alpha 1.0 \
            $device_arg \
            --batch-size 64 \
            --disable-device-locking

    # undo tag

    cat $translations_sub/$corpus.tag.$trg | python $scripts/preprocessing/remove_tag_from_translations.py --verbose > $translations_sub/$corpus.bpe.$trg

    # undo BPE

    cat $translations_sub/$corpus.bpe.$trg | sed -r 's/@@( |$)//g' > $translations_sub/$corpus.tok.$trg

    # undo tokenization

    cat $translations_sub/$corpus.tok.$trg | $MOSES/tokenizer/detokenizer.perl -l $trg > $translations_sub/$corpus.$trg

done
