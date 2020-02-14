#! /bin/bash

# calling script needs to set:

# $evaluations_lm_sub
# $preprocessed_lm_sub
# $models_lm_sub

log_file=$evaluations_lm_sub/log

fairseq-eval-lm $preprocessed_lm_sub \
    --path $models_lm_sub/checkpoint_best.pt \
    --max-sentences 2 \
    --tokens-per-sample 512 \
    --context-window 400 2>&1 | tee -a $log_file
