#! /bin/bash

base=/Users/mathiasmuller/Desktop/noise-distill-tensorboard-logs/weights

dataset_names="raw_paracrawl.100.filtered"
methods="ignore only min max mean"
align_models="baseline baseline.word_level raw_paracrawl.100 raw_paracrawl.100.word_level raw_paracrawl.100.filtered raw_paracrawl.100.filtered.word_level"

for dataset in $dataset_names; do
    for method in $methods; do
        for model in $align_models; do
            sub=$base/$dataset.$model.$method
            mkdir -p $sub
            scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/$dataset.$model.$method/sample $sub/sample

        done
    done
done

scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/train.bpe.sample.* $base/

wc -l $base/* $base/*/*
