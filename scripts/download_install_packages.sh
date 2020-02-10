#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

tools=$base/tools
mkdir -p $tools

source $base/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

# install Sockeye

# CUDA version on instance
CUDA_VERSION=100

## Method A: install from PyPi

wget https://raw.githubusercontent.com/awslabs/sockeye/master/requirements/requirements.gpu-cu${CUDA_VERSION}.txt
pip install sockeye --no-deps -r requirements.gpu-cu${CUDA_VERSION}.txt
rm requirements.gpu-cu${CUDA_VERSION}.txt

pip install matplotlib mxboard

# install BPE library

pip install subword-nmt

# install sacrebleu for evaluation

pip install sacrebleu

# install Moses scripts for preprocessing

git clone https://github.com/bricksdont/moses-scripts $tools/moses-scripts

# install fasttext for language identification

pip install fasttext

###########################################

# THEN source VPU env and do the same again

deactivate
echo "check current python after deactivate:"
which python

source $base/venvs/sockeye3-cpu/bin/activate

echo "check current python after sourcing CPU env:"
which python

wget https://raw.githubusercontent.com/awslabs/sockeye/master/requirements/requirements.txt
pip install sockeye --no-deps -r requirements.txt
rm requirements.txt

pip install matplotlib mxboard

# install BPE library

pip install subword-nmt

# install sacrebleu for evaluation

pip install sacrebleu

# install fasttext for language identification

pip install fasttext

# download fasttext model

mkdir -p $tools/fasttext

wget https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin -P $tools/fasttext
