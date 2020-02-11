#! /bin/bash

# calling process needs to set

# $scripts
# $src
# $trg
# $input_src
# $input_trg
# $output_src
# $output_trg
# $tools

python $scripts/preprocessing/apply_filter_rules.py \
          --src-lang $src \
          --trg-lang $trg \
          --input-src $input_src \
          --input-trg $input_trg \
          --output-src $output_src \
          --output-trg $output_trg \
          --rules all \
          --fasttext-model-path $tools/fasttext/lid.176.bin

