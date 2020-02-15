#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate

src=de
trg=en

scripts=$base/scripts
scores=$base/scores
scores_lm=$base/scores_lm

dcce_method="adq-dom"

for scores_sub in $scores/*; do

  echo "scores_sub: $scores_sub"

  name=$(basename $scores_sub)

  filtered_sub=$scores/$name
  scores_lm_sub=$scores_lm/$name

  if [[ -f $scores_sub/scores.$dcce_method.dcce ]]; then
    echo "File exists: $scores_sub/scores.$dcce_method.dcce"
    echo "Skipping"
    continue
  fi

  python $scripts/scoring/dual_conditional_cross_entropy_scoring.py \
    --scores-nmt-forward $scores_sub/scores.nmt.forward \
    --scores-nmt-backward $scores_sub/scores.nmt.backward \
    --scores-lm-indomain $scores_lm_sub/scores.lm.indomain \
    --scores-lm-outdomain $scores_lm_sub/scores.lm.outdomain \
    --method $dcce_method \
    --output $scores_sub/scores.$dcce_method.dcce \
    --src-lang $src \
    --trg-lang $trg

    # create better view of the data

    paste $scores_sub/scores.$dcce_method.dcce $filtered_sub/train.bpe.$src $filtered_sub/train.bpe.$trg > $scores_sub/scores.$dcce_method.all

    # reverse numerical sort

    cat $scores_sub/scores.$dcce_method.all | sort -rn > $scores_sub/scores.$dcce_method.all.sorted

done