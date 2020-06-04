#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec

# virtualenv must be installed on your system, install with e.g.
# pip install virtualenv

mkdir -p $base/venvs

# python3 needs to be installed on your system

virtualenv -p python3 $base/venvs/sockeye3

# second one for mxnet on CPU

virtualenv -p python3 $base/venvs/sockeye3-cpu

# third one for LASER

virtualenv -p python3 $base/venvs/laser3

# fourth/fifth one for custom sockeye

virtualenv -p python3 $base/venvs/sockeye3-custom

virtualenv -p python3 $base/venvs/sockeye3-custom-cpu

echo "To activate your environment, e.g.:"
echo "    source $base/venvs/sockeye3/bin/activate"
