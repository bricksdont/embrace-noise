#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate

src=de
trg=en

scripts=$base/scripts

data=$base/data
preprocessed=$base/preprocessed
filtered=$base/filtered

mined=$base/mined
dcce=$base/dcce

shared_models=$base/shared_models

MOSES=$base/tools/moses-scripts/scripts

bpe_vocab_threshold=50

shopt -s nullglob

for mined_sub in $mined/*; do

    mining_method=score

    model_name=$(basename $mined_sub)

    model_name=$model_name.mined.$mining_method.instance_weighting
    data_sub=$data/$model_name

    if [[ -d $data_sub ]]; then
      echo "data_sub exists: $data_sub"
      echo "Skipping."
      continue
    fi

    num_lines_baseline=`cat $data/baseline/train.bpe.$src | wc -l`

    origin_sub=$(mktemp -d)

    cat $mined_sub/mined.$mining_method.sorted | cut -f2 > $origin_sub/train.$src
    cat $mined_sub/mined.$mining_method.sorted | cut -f3 > $origin_sub/train.$trg

    python $scripts/preprocessing/create_weights.py --method ones --size $num_lines_baseline > $origin_sub/scores.1

    cut -f1 $mined_sub/mined.$mining_method.sorted | python $scripts/preprocessing/min_max_scaling.py > $origin_sub/scores.2

    mkdir -p $data_sub

    cat $origin_sub/scores.1 $origin_sub/scores.2 > $data_sub/train.weights

    for lang in $src $trg; do
      cat $origin_sub/train.$lang | perl $MOSES/tokenizer/normalize-punctuation.perl $lang > $origin_sub/train.normalized.$lang
      cat $origin_sub/train.normalized.$lang | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $lang > $origin_sub/train.tok.$lang

      subword-nmt apply-bpe -c $shared_models/baseline/$src$trg.bpe \
      --vocabulary $shared_models/baseline/vocab.$lang \
      --vocabulary-threshold $bpe_vocab_threshold < $origin_sub/train.tok.$lang > $origin_sub/train.bpe.$lang
    done

    . $scripts/preprocessing/concat_with_baseline_generic.sh

done

for dcce_sub in $dcce/*; do

  for dcce_method in adq adq-dom; do

      model_name=$(basename $dcce_sub)

      model_name=$model_name.dcce.$dcce_method.instance_weighting
      data_sub=$data/$model_name

      if [[ -d $data_sub ]]; then
        echo "data_sub exists: $data_sub"
        echo "Skipping."
        continue
      fi

      num_lines_baseline=`cat $data/baseline/train.bpe.$src | wc -l`

      origin_sub=$(mktemp -d)

      cat $dcce_sub/scores.$dcce_method.all.sorted | cut -f2 > $origin_sub/train.bpe.$src
      cat $dcce_sub/scores.$dcce_method.all.sorted | cut -f3 > $origin_sub/train.bpe.$trg

      python $scripts/preprocessing/create_weights.py --method ones --size $num_lines_baseline > $origin_sub/scores.1

      cut -f1 $dcce_sub/scores.$dcce_method.all.sorted | python $scripts/preprocessing/min_max_scaling.py > $origin_sub/scores.2

      mkdir -p $data_sub

      cat $origin_sub/scores.1 $origin_sub/scores.2 > $data_sub/train.weights

      . $scripts/preprocessing/concat_with_baseline_generic.sh

  done
done
