#! /bin/bash

# virtualenv must be installed on your system, install with e.g.
# pip install virtualenv

scripts=`dirname "$0"`
base=$scripts/..

mkdir -p $base/venvs

# python3 needs to be installed on your system

virtualenv -p python3 $base/venvs/sockeye3

# second one for mxnet on CPU

virtualenv -p python3 $base/venvs/sockeye3-cpu

# third one for LASER

virtualenv -p python3 $base/venvs/laser3

# fourth one for fairseq

pyenv local 3.6.0

virtualenv -p python3 $base/venvs/fairseq3

echo "To activate your environment, e.g.:"
echo "    source $base/venvs/sockeye3/bin/activate"
