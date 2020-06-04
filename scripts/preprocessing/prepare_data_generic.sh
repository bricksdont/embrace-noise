#! /bin/bash

# calling script has to set:

# $data_sub
# $prepared_sub
# $src
# $trg
# $mode

# measure time

SECONDS=0

data_sub=$1
prepared_sub=$2
src=$3
trg=$4
mode=$5

cmd="python -m sockeye.prepare_data -s $data_sub/train.$mode.$src -t $data_sub/train.$mode.$trg --shared-vocab -o $prepared_sub"

echo "Executing:"
echo "$cmd"

python -m sockeye.prepare_data \
                        -s $data_sub/train.$mode.$src \
                        -t $data_sub/train.$mode.$trg \
			                  --shared-vocab \
                        -o $prepared_sub

echo "time taken:"
echo "$SECONDS seconds"
