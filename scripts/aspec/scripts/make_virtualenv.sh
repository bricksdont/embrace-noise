#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec

# virtualenv must be installed on your system, install with e.g.
# pip install virtualenv

mkdir -p $base/venvs

# third one for LASER

virtualenv -p python3 $base/venvs/laser3

echo "To activate your environment, e.g.:"
echo "    source $base/venvs/laser3/bin/activate"
