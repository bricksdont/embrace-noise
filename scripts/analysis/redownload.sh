#! /bin/bash

base=/Users/mathiasmuller/Desktop/noise-distill-tensorboard-logs/weights

dataset_names="raw_paracrawl.100.filtered"
methods="ignore only min max mean geomean"
align_models="baseline baseline.word_level raw_paracrawl.100 raw_paracrawl.100.word_level raw_paracrawl.100.filtered raw_paracrawl.100.filtered.word_level"

for dataset in $dataset_names; do
    for method in $methods; do
        for model in $align_models; do
            sub=$base/$dataset.$model.$method
            mkdir -p $sub
            scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/$dataset.$model.$method/sample $sub/sample
            scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/$dataset.$model.$method/sample2 $sub/sample2
        done
    done
done

# smoothed versions for word-level models

dataset_names="raw_paracrawl.100.filtered"
methods="ignore only min max mean geomean"
align_models="baseline.word_level raw_paracrawl.100.word_level raw_paracrawl.100.filtered.word_level"

for dataset in $dataset_names; do
    for method in $methods; do
        for model in $align_models; do
            sub=$base/$dataset.$model.$method.smooth
            mkdir -p $sub
            scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/$dataset.$model.$method.smooth/sample $sub/sample
            scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/$dataset.$model.$method.smooth/sample2 $sub/sample2
        done
    done
done

scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/train.bpe.sample.* $base/
scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/train.bpe.sample2.* $base/

wc -l $base/* $base/*/*
