#! /bin/bash

# calling script has to set:

# $data_sub
# $prepared_sub
# $instance_weighting_type
# $src
# $trg
# $mode

# measure time

SECONDS=0

data_sub=$1
prepared_sub=$2
instance_weighting_type=$3
src=$4
trg=$5
mode=$6

cmd="python -m sockeye.prepare_data -s $data_sub/train.$mode.$src -t $data_sub/train.$mode.$trg --shared-vocab -o $prepared_sub --instance-weighting --instance-weights-file $data_sub/train.weights --instance-weighting-type $instance_weighting_type "

echo "Executing:"
echo "$cmd"

python -m sockeye.prepare_data \
                        -s $data_sub/train.$mode.$src \
                        -t $data_sub/train.$mode.$trg \
			                  --shared-vocab \
                        -o $prepared_sub \
                        --instance-weighting \
                        --instance-weights-file $data_sub/train.weights \
                        --instance-weighting-type $instance_weighting_type

echo "time taken:"
echo "$SECONDS seconds"
