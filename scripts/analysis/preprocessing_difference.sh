#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

MOSES=$base/tools/moses-scripts/scripts

filtered=$base/filtered
scripts=$base/scripts
shared_models=$base/shared_models

analysis_sub=$base/analysis/preprocessing_difference

mkdir -p $analysis_sub

src=de
trg=en

bpe_vocab_threshold=50

for lang in $src $trg; do
    ln -snf $filtered/raw_paracrawl.100/train.$lang $analysis_sub/train.$lang
    ln -snf $filtered/raw_paracrawl.100/train.bpe.$lang $analysis_sub/train.bpe.$lang
done

for lang in $src $trg; do
    cat $analysis_sub/train.$lang | perl $MOSES/tokenizer/normalize-punctuation.perl $lang > $analysis_sub/train.normalized2.$lang
    cat $analysis_sub/train.normalized2.$lang | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $lang > $analysis_sub/train.tok2.$lang

    subword-nmt apply-bpe -c $shared_models/baseline/$src$trg.bpe \
            --vocabulary $shared_models/baseline/vocab.$lang \
            --vocabulary-threshold $bpe_vocab_threshold < $analysis_sub/train.tok2.$lang > $analysis_sub/train.bpe2.$lang
done

file_a=$analysis_sub/train.bpe.de
file_b=$analysis_sub/train.bpe2.de

python $scripts/analysis/sentence_pair_overlap.py --inputs $file_a $file_b

file_a=$analysis_sub/train.bpe.en
file_b=$analysis_sub/train.bpe2.en

python $scripts/analysis/sentence_pair_overlap.py --inputs $file_a $file_b
