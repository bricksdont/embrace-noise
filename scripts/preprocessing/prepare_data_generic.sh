#! /bin/bash

# calling script has to set:

# $data_sub
# $prepared_sub

data_sub=$1
prepared_sub=$2

src=de
trg=en

python -m sockeye.prepare_data \
                        -s $data_sub/train.bpe.$src \
                        -t $data_sub/train.bpe.$trg \
			                  --shared-vocab \
                        -o $prepared_sub
