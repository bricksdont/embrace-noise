#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate

src=de
trg=en

scripts=$base/scripts
data=$base/data
filtered=$base/filtered

modelfront=$base/modelfront

mkdir -p $modelfront

for name in raw_paracrawl.100; do

  filtered_sub=$filtered/$name
  modelfront_sub=$modelfront/$name

  if [[ -d $modelfront_sub ]]; then
                echo "data_sub exists: $modelfront_sub"
                echo "Skipping."
                continue
  fi

  mkdir -p $modelfront_sub

  for lang in $src $trg; do
    ln -snf $filtered_sub/train.$lang $modelfront_sub/train.$lang
  done

  python $scripts/modelfront/request_scores.py \
      --src $modelfront_sub/train.$src \
      --trg $modelfront_sub/train.$trg \
      --scores $modelfront_sub/scores

done
