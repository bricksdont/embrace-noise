#! /bin/bash

# calling script has to set:

# $base
# $noise_type
# $noise_amount

data=$base/data
scripts=$base/scripts

src=de
trg=en

prepared=$data/prepared
prepared_individual=$prepared/$noise_type.$noise_amount

mkdir -p $prepared
mkdir -p $prepared_individual

python -m sockeye.prepare_data \
                        -s $data/train/$noise_type/train.$noise_amount.tok.$src \
                        -t $data/train/$noise_type/train.$noise_amount.tok.$trg \
			                  --shared-vocab \
                        -o $prepared_individual
