#! /bin/bash

# calling script needs to set:

# $basebase
# $data_sub
# $translations_sub
# $model_path
# $src
# $trg
# $mode

basebase=$1
data_sub=$2
translations_sub=$3
model_path=$4
src=$5
trg=$6
mode=$7

MOSES=$basebase/tools/moses-scripts/scripts

num_threads=1
device_arg="--device-ids 0"

for corpus in dev test; do

    if [[ -s $translations_sub/$corpus.$mode.$trg ]]; then
      echo "File exists: $translations_sub/$corpus.$mode.$trg"
      echo "Skipping"
      continue
    fi

    # produce nbest list, desired beam size, desired batch size

    # 1-best, fixed beam size, fixed batch size

    OMP_NUM_THREADS=$num_threads python -m sockeye.translate \
            -i $data_sub/$corpus.$mode.$src \
            -o $translations_sub/$corpus.$mode.$trg \
            -m $model_path \
            --beam-size 10 \
            --length-penalty-alpha 1.0 \
            $device_arg \
            --batch-size 64 \
            --disable-device-locking

    # undo bpe or pieces

    if [[ $mode == "pieces" ]]; then

        cat $translations_sub/$corpus.$mode.$trg | \
            python $basebase/scripts/aspec/scripts/remove_sentencepiece.py \
                --model $basebase/aspec/shared_models/baseline/enja.sentencepiece.model \
                > $translations_sub/$corpus.tok.$trg
    else
        # assume mode is bpe

        cat $translations_sub/$corpus.$mode.$trg | sed -r 's/@@( |$)//g' > $translations_sub/$corpus.tok.$trg
    fi

    # undo tokenization

    if [[ $trg == "ja" ]]; then

      # remove juman tokenization
      # see http://lotus.kuee.kyoto-u.ac.jp/WAT/WAT2019/baseline/baselineSystemNMT.html

      cat $translations_sub/$corpus.tok.$trg | \
          perl -Mencoding=utf8 -pe 's/([^Ａ-Ｚａ-ｚA-Za-z]) +/${1}/g; s/ +([^Ａ-Ｚａ-ｚA-Za-z])/${1}/g; ' \
              > $translations_sub/$corpus.$trg
    else
      # assume trg is en

      cat $translations_sub/$corpus.tok.$trg | $MOSES/tokenizer/detokenizer.perl -l $trg > $translations_sub/$corpus.$trg
    fi

done
