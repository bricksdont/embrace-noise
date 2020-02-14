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

# THEN source CPU env and do the same again

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

###########################################

# THEN source LASER env and do the same again

deactivate
echo "check current python after deactivate:"
which python

source $base/venvs/laser3/bin/activate

echo "check current python after sourcing LASER env:"
which python

# install torch

wget https://download.pytorch.org/whl/cu100/torch-1.3.0%2Bcu100-cp35-cp35m-linux_x86_64.whl

pip install torch-1.3.0+cu100-cp35-cp35m-linux_x86_64.whl

rm torch-1.3.0+cu100-cp35-cp35m-linux_x86_64.whl

# cython, numpy, transliterate: needed by fastBPE (dependency of LASER)

pip install Cython numpy transliterate

git clone https://github.com/facebookresearch/LASER.git $tools/laser

export LASER=$tools/laser

. $tools/laser/install_external_tools.sh

. $tools/laser/install_models.sh

# install FAISS

pip install faiss-gpu

# install fasttext for language identification

pip install fasttext

# download fasttext model

mkdir -p $tools/fasttext

wget https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin -P $tools/fasttext

##############################

# third VM for fairseq (needs Python 3.6)

# source fairseq env and do the same again

deactivate
echo "check current python after deactivate:"
which python

source $base/venvs/fairseq3/bin/activate

echo "check current python after sourcing fairseq env:"
which python

# install torch

wget https://download.pytorch.org/whl/cu100/torch-1.3.0%2Bcu100-cp36-cp36m-linux_x86_64.whl

pip install torch-1.3.0+cu100-cp36-cp36m-linux_x86_64.whl

rm torch-1.3.0+cu100-cp36-cp36m-linux_x86_64.whl

pip install Cython numpy

# install fairseq for language models

pip install fairseq
