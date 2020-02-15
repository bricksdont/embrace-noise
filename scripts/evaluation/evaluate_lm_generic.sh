#! /bin/bash

# calling script needs to set:

# $evaluations_lm_sub
# $preprocessed_lm_sub
# $models_lm_sub

evaluations_lm_sub=$1
preprocessed_lm_sub=$2
models_lm_sub=$3

log_file=$evaluations_lm_sub/log

fairseq-eval-lm $preprocessed_lm_sub \
    --path $models_lm_sub/checkpoint_best.pt \
    --max-sentences 2 \
    --tokens-per-sample 512 \
    --context-window 400 2>&1 | tee -a $log_file
