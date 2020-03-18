#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

tools=$base/tools

(cd $tools/sockeye-custom && git pull)

source $base/venvs/sockeye3-custom/bin/activate

pip install --upgrade --no-deps $tools/sockeye-custom

deactivate

source $base/venvs/sockeye3-custom-cpu/bin/activate

pip install --upgrade --no-deps $tools/sockeye-custom
