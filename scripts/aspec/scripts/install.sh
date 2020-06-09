#! /bin/bash

basebase=/net/cephfs/home/mathmu/scratch/noise-distill
base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec

tools=$base/tools

mkdir -p $tools

module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

source $basebase/venvs/sockeye3/bin/activate

pip install --upgrade sentencepiece

###########################################

# THEN source CPU env and do the same again

deactivate
echo "check current python after deactivate:"
which python

source $basebase/venvs/sockeye3-cpu/bin/activate

echo "check current python after sourcing CPU env:"
which python

# install sentencepiece for subword regularization

pip install --upgrade sentencepiece

###########################################

# source sockeye custom env

deactivate
echo "check current python after deactivate:"
which python

source $basebase/venvs/sockeye3-custom/bin/activate

echo "check current python after sourcing Sockeye custom env:"
which python

# install sentencepiece for subword regularization

pip install --upgrade sentencepiece

###########################################

# source sockeye custom env cpu

deactivate
echo "check current python after deactivate:"
which python

source $basebase/venvs/sockeye3-custom-cpu/bin/activate

echo "check current python after sourcing Sockeye custom env:"
which python

# install sentencepiece for subword regularization

pip install --upgrade sentencepiece

###########################################

# THEN source LASER env and do the same again

deactivate
echo "check current python after deactivate:"
which python

source $base/venvs/laser3/bin/activate

echo "check current python after sourcing LASER env:"
which python

# install torch

wget https://download.pytorch.org/whl/cu100/torch-1.3.0%2Bcu100-cp36-cp36m-linux_x86_64.whl

pip install torch-1.3.0+cu100-cp36-cp36m-linux_x86_64.whl

rm torch-1.3.0+cu100-cp36-cp36m-linux_x86_64.whl

# cython, numpy, transliterate: needed by fastBPE (dependency of LASER)

pip install Cython numpy transliterate

git clone https://github.com/yannvgn/LASER.git $tools/laser

export LASER=$tools/laser

# unanswered PR that gets installation of Mecab right

(cd $tools/laser && git checkout mecab-installation)

. $tools/laser/install_external_tools.sh --install-mecab

. $tools/laser/install_models.sh

# install FAISS

pip install faiss-gpu

# install fasttext for language identification

pip install fasttext

# download fasttext model

mkdir -p $tools/fasttext

wget https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin -P $tools/fasttext

pip install sacrebleu

# japanese tokenizer for sacrebleu

pip install mecab-python3

# install juman

wget "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/juman/juman-7.01.tar.bz2&name=juman-7.01.tar.bz2"

mv "lime.cgi\?down\=http\:%2F%2Fnlp.ist.i.kyoto-u.ac.jp%2Fnl-resource%2Fjuman%2Fjuman-7.01.tar.bz2\&name\=juman-7.01.tar.bz2" $tools/juman.tar.bz2

tar xjvf $tools/juman.tar.bz2

rm $tools/juman.tar.bz2

(cd $tools/juman-7.01 && ./configure --prefix=$tools)
(cd $tools/juman-7.01 && make)
(cd $tools/juman-7.01 && make install)

# must be exported again before use

export LD_LIBRARY_PATH=$tools/usr/local/lib

# edit hard-coded paths

sed -i "s/\/usr/\/net\/cephfs\/scratch\/mathmu\/noise-distill\/aspec\/tools\/usr/g" $tools/usr/local/etc/jumanrc

# might need to be set again before use

alias juman="$tools/usr/local/bin/juman -r $tools/usr/local/etc/jumanrc"
