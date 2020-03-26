#! /bin/bash

MODEL_LIST=(
  "baseline"
  "baseline.filtered"
  "baseline.distilled"
  "raw_paracrawl.100"
  "raw_paracrawl.100.tagged"
  "raw_paracrawl.100.filtered"
  "raw_paracrawl.100.filtered.tagged"
  "raw_paracrawl.100.distilled"
  "raw_paracrawl.100.dcce.adq.0.25"
  "raw_paracrawl.100.dcce.adq-dom.0.25"
  "raw_paracrawl.100.dcce.adq-dom.0.5"
  "raw_paracrawl.100.dcce.adq-dom.0.75"
  "raw_paracrawl.100.mined.mine.0.25"
  "raw_paracrawl.100.mined.mine.0.5"
  "raw_paracrawl.100.mined.mine.0.75"
  "raw_paracrawl.100.mined.score.0.25"
  "raw_paracrawl.100.mined.score.instance_weighting"
  "raw_paracrawl.100.dcce.adq.instance_weighting"
  "raw_paracrawl.100.dcce.adq-dom.instance_weighting"
)

base=/Users/mathiasmuller/Desktop/noise-distill-tensorboard-logs

mkdir -p $base

for model in "${MODEL_LIST[@]}"; do
    model_sub=$base/$model

    if [[ ! -d $model_sub ]]; then
      mkdir $model_sub

      scp mathmu@login0.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/models/$model/tensorboard/* $model_sub/
    fi
done

if [[ ! -d $base/env ]]; then

  virtualenv -p python $base/env

  source $base/env/bin/activate

  pip install tensorboard

else
  source $base/env/bin/activate
fi

open -a firefox http://localhost:6007

tensorboard --port 6007 --logdir $base
