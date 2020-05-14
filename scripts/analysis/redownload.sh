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
smooth_methods="pre-3 pre-3-edge post-3 post-3-edge"
align_models="raw_paracrawl.100.filtered.word_level"

for dataset in $dataset_names; do
    for method in $methods; do
        for smooth_method in $smooth_methods; do
            for model in $align_models; do
                sub=$base/$dataset.$model.$method.$smooth_method
                mkdir -p $sub
                scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/$dataset.$model.$method.$smooth_method/sample $sub/sample
                scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/$dataset.$model.$method.$smooth_method/sample2 $sub/sample2
            done
        done
    done
done

scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/train.bpe.sample.* $base/
scp mathmu@login.s3it.uzh.ch:/net/cephfs/scratch/mathmu/noise-distill/alignments/train.bpe.sample2.* $base/

wc -l $base/* $base/*/*
