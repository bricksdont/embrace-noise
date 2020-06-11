#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $basebase/venvs/sockeye3-cpu/bin/activate

src=en
trg=ja

scripts=$basebase/scripts
scores=$base/scores
filtered=$base/filtered

dcce=$base/dcce

mkdir -p $dcce

for scores_sub in $scores/*; do

  echo "scores_sub: $scores_sub"

  name=$(basename $scores_sub)

  filtered_sub=$filtered/$name

  dcce_sub=$dcce/$name

  mkdir -p $dcce_sub

  dcce_method="adq"

  if [[ -f $dcce_sub/scores.$dcce_method ]]; then
    echo "File exists: $dcce_sub/scores.$dcce_method"
    echo "Skipping"
    continue
  fi

  python $scripts/scoring/dual_conditional_cross_entropy_scoring.py \
    --scores-nmt-forward $scores_sub/scores.nmt.forward \
    --scores-nmt-backward $scores_sub/scores.nmt.backward \
    --method $dcce_method \
    --output $dcce_sub/scores.$dcce_method \
    --src-lang $src \
    --trg-lang $trg

    # create better view of the data

    paste $dcce_sub/scores.$dcce_method $filtered_sub/train.bpe.$src $filtered_sub/train.bpe.$trg > $dcce_sub/scores.$dcce_method.all

    # reverse numerical sort

    cat $dcce_sub/scores.$dcce_method.all | sort -rn > $dcce_sub/scores.$dcce_method.all.sorted

done
