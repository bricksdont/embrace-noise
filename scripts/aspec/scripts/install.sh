#! /bin/bash

basebase=/net/cephfs/home/mathmu/scratch/noise-distill
base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec

module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

source $basebase/venvs/sockeye3/bin/activate

pip install sentencepiece

###########################################

# THEN source CPU env and do the same again

deactivate
echo "check current python after deactivate:"
which python

source $basebase/venvs/sockeye3-cpu/bin/activate

echo "check current python after sourcing CPU env:"
which python

# install sentencepiece for subword regularization

pip install sentencepiece

###########################################

# source sockeye custom env

deactivate
echo "check current python after deactivate:"
which python

source $basebase/venvs/sockeye3-custom/bin/activate

echo "check current python after sourcing Sockeye custom env:"
which python

# install sentencepiece for subword regularization

pip install sentencepiece

###########################################

# source sockeye custom env cpu

deactivate
echo "check current python after deactivate:"
which python

source $basebase/venvs/sockeye3-custom-cpu/bin/activate

echo "check current python after sourcing Sockeye custom env:"
which python

# install sentencepiece for subword regularization

pip install sentencepiece

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

git clone https://github.com/yannvgn/LASER.git $tools/laser

export LASER=$tools/laser

# unanswered PR that gets installation of Mecab right

(cd $tools/laser && checkout mecab-installation)

. $tools/laser/install_external_tools.sh

. $tools/laser/install_models.sh

# install FAISS

pip install faiss-gpu

# install fasttext for language identification

pip install fasttext

# download fasttext model

mkdir -p $tools/fasttext

wget https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin -P $tools/fasttext

# install fast_align

git clone https://github.com/clab/fast_align $tools/fast_align
(cd $tools/fast_align && mkdir build)
(cd $tools/fast_align/build && cmake ..)
(cd $tools/fast_align/build && make)

# fast_align helper tools

(cd $tools && wget https://raw.githubusercontent.com/redpony/cdec/master/corpus/paste-files.pl)
(cd $tools && wget https://raw.githubusercontent.com/redpony/cdec/master/corpus/filter-length.pl)
