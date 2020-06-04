#! /bin/bash

# calling script has to set:

# $data_sub
# $shared_models_sub
# $scripts
# $sentencepiece_vocab_size
# $src
# $trg

data_sub=$1
shared_models_sub=$2
scripts=$3
sentencepiece_vocab_size=$4
src=$5
trg=$6

# measure time

SECONDS=0

#################

echo "data_sub: $data_sub"

# concat training material

if [[ ! -f $data_sub/train.both ]]; then
    cat $data_sub/train.$src $data_sub/train.$trg > $data_sub/train.both
fi

# learn sentencepiece model on train (concatenate both languages)

if [[ ! -f $shared_models_sub/$src$trg.sentencepiece.model ]]; then

  python $scripts/train_sentencepiece.py \
    --model-prefix $shared_models_sub/$src$trg.sentencepiece \
    --input $data_sub/train.both \
    --vocab-size $sentencepiece_vocab_size

else
  echo "Sentencepiece model exists: $shared_models_sub/$src$trg.sentencepiece.model"
  echo "Skipping model training"
fi

# apply SP model to train, test and dev

for corpus in train dev test; do
    for lang in $src $trg; do
        cat $data_sub/$corpus.truecased.$lang | \
            python $scripts/apply_sentencepiece.py \
                --model $shared_models_sub/$src$trg.sentencepiece.model \
                --nbest-size 1 --output-format nbest \
                    > $data_sub/$corpus.pieces.$lang
    done
done

# sizes
echo "Sizes of all files:"

wc -l $data_sub/*
wc -l $shared_models_sub/*

# sanity checks
echo "At this point, please make sure that 1) number of lines are as expected, 2) language suffixes are correct and 3) files are parallel"

echo "time taken:"
echo "$SECONDS seconds"
