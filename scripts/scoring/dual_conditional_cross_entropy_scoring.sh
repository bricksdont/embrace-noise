#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate

src=de
trg=en

scripts=$base/scripts
scores=$base/scores
filtered=$base/filtered
scores_lm=$base/scores_lm

dcce=$base/dcce

mkdir -p $dcce

for scores_sub in $scores/*; do

  echo "scores_sub: $scores_sub"

  name=$(basename $scores_sub)

  filtered_sub=$filtered/$name
  scores_lm_sub=$scores_lm/$name

  dcce_sub=$dcce/$name

  mkdir -p $dcce_sub

  for dcce_method in adq adq-dom; do

      if [[ -d $dcce_sub/scores.$dcce_method ]]; then
        echo "File exists: $dcce_sub/scores.$dcce_method"
        echo "Skipping"
        continue
      fi

      python $scripts/scoring/dual_conditional_cross_entropy_scoring.py \
        --scores-nmt-forward $scores_sub/scores.nmt.forward \
        --scores-nmt-backward $scores_sub/scores.nmt.backward \
        --scores-lm-indomain $scores_lm_sub/scores.lm.indomain \
        --scores-lm-outdomain $scores_lm_sub/scores.lm.outdomain \
        --method $dcce_method \
        --output $dcce_sub/scores.$dcce_method \
        --src-lang $src \
        --trg-lang $trg

        # create better view of the data

        paste $dcce_sub/scores.$dcce_method $filtered_sub/train.bpe.$src $filtered_sub/train.bpe.$trg > $dcce_sub/scores.$dcce_method.all

        # reverse numerical sort

        cat $dcce_sub/scores.$dcce_method.all | sort -rn > $dcce_sub/scores.$dcce_method.all.sorted

    done
done
