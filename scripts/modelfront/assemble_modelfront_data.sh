#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate

src=de
trg=en

scripts=$base/scripts

data=$base/data
filtered=$base/filtered
modelfront=$base/modelfront

shared_models=$base/shared_models

MOSES=$base/tools/moses-scripts/scripts

bpe_vocab_threshold=50

shopt -s nullglob

for modelfront_sub in $modelfront/*; do

  for fraction in 0.25 0.5 0.75; do

      model_name=$(basename $modelfront_sub)
      original_name=$model_name

      model_name=$model_name.modelfront.$fraction
      data_sub=$data/$model_name

      if [[ -d $data_sub ]]; then
        echo "data_sub exists: $data_sub"
        echo "Skipping."
        continue
      fi

      num_lines=`cat $filtered/$original_name/train.bpe.$src | wc -l`

      origin_sub=$(mktemp -d)

      cat $modelfront_sub/scores.sorted | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines | cut -f2 > $origin_sub/train.$src
      cat $modelfront_sub/scores.sorted | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines | cut -f3 > $origin_sub/train.$trg

      for lang in $src $trg; do
        cat $origin_sub/train.$lang | perl $MOSES/tokenizer/normalize-punctuation.perl $lang > $origin_sub/train.normalized.$lang
        cat $origin_sub/train.normalized.$lang | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $lang > $origin_sub/train.tok.$lang

        subword-nmt apply-bpe -c $shared_models/baseline/$src$trg.bpe \
        --vocabulary $shared_models/baseline/vocab.$lang \
        --vocabulary-threshold $bpe_vocab_threshold < $origin_sub/train.tok.$lang > $origin_sub/train.bpe.$lang
      done

    . $scripts/preprocessing/concat_with_baseline_generic.sh

  done
done

