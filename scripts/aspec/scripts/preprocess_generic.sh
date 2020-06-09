#! /bin/bash

# calling script has to set:

# $data_sub
# $shared_models_sub
# $base
# $basebase
# $src
# $trg
# $bpe_total_symbols
# $bpe_vocab_threshold

data_sub=$1
shared_models_sub=$2
basebase=$3
src=$4
trg=$5
bpe_total_symbols=$6
bpe_vocab_threshold=$7

tools=$basebase/aspec/tools
MOSES=$basebase/tools/moses-scripts/scripts

export LD_LIBRARY_PATH=$tools/usr/local/lib

# measure time

SECONDS=0

#################

echo "data_sub: $data_sub"

for lang in $src $trg; do
    for corpus in train dev test; do
        if [[ ! -f $data_sub/$corpus.tok.$lang ]]; then

            if [[ $lang == "ja" ]]; then
              # juman tokenization
              # see http://lotus.kuee.kyoto-u.ac.jp/WAT/WAT2019/baseline/dataPreparationJE.html

              cat $data_sub/$corpus.$lang | \
                perl -CSD -Mutf8 -pe 's/　/ /g;' | \
                $tools/usr/local/bin/juman -r $tools/usr/local/etc/jumanrc -b | \
                perl -ne 'chomp; if($_ eq "EOS"){print join(" ",@b),"\n"; @b=();} else {@a=split/ /; push @b, $a[0];}' | \
                perl -pe 's/^ +//; s/ +$//; s/ +/ /g;' | \
                perl -CSD -Mutf8 -pe 'tr/\|[]/｜［］/; ' \
                > $data_sub/$corpus.tok.$lang

            else
              # assume lang is en, Moses tokenization

              cat $data_sub/$corpus.$lang | \
                perl $MOSES/tokenizer/tokenizer.perl -a -q -no-escape -l $lang > $data_sub/$corpus.tok.$lang
            fi
        fi
    done
done

# learn and apply BPE model on train (concatenate both languages)

. $basebase/scripts/preprocessing/preprocess_generic.sh \
            $data_sub $shared_models_sub $bpe_vocab_threshold $bpe_total_symbols $src $trg

# sizes
echo "Sizes of all files:"

wc -l $data_sub/*
wc -l $shared_models_sub/*

# sanity checks
echo "At this point, please make sure that 1) number of lines are as expected, 2) language suffixes are correct and 3) files are parallel"

echo "time taken:"
echo "$SECONDS seconds"
