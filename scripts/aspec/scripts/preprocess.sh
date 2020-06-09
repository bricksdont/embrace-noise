#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

scripts=/net/cephfs/home/mathmu/scratch/noise-distill/scripts/aspec/scripts

source $basebase/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hpc

src=en
trg=ja

data=$base/data
shared_models=$base/shared_models

mkdir -p $shared_models

bpe_total_symbols=16000
bpe_vocab_threshold=10

# extract sentences in raw folder

# taken from: http://lotus.kuee.kyoto-u.ac.jp/WAT/WAT2019/baseline/dataPreparationJE.html

for corpus in dev test; do
  perl -ne 'chomp; @a=split/ \|\|\| /; print $a[2], "\n";' < $data/raw/$corpus/$corpus.txt > $data/raw/$corpus/$corpus.extracted.ja
  perl -ne 'chomp; @a=split/ \|\|\| /; print $a[3], "\n";' < $data/raw/$corpus/$corpus.txt > $data/raw/$corpus/$corpus.extracted.en
done

for corpus in train-1 train-2 train-3; do
  perl -ne 'chomp; @a=split/ \|\|\| /; print $a[3], "\n";' < $data/raw/train/$corpus.txt > $data/raw/train/$corpus.extracted.ja
  perl -ne 'chomp; @a=split/ \|\|\| /; print $a[4], "\n";' < $data/raw/train/$corpus.txt > $data/raw/train/$corpus.extracted.en
done

# (Removing date expressions at EOS in Japanese in the training and development data to reduce noise)
# TODO: necessary for weighting schemes?

for corpus in train-1 train-2 train-3; do
  cat $data/raw/train/$corpus.extracted.ja | perl -CSD -Mutf8 -pe 's/(.)［[０-９．]+］$/${1}/;' > $data/raw/train/$corpus.cleaned.ja
done

for corpus in dev; do
  cat $data/raw/$corpus/$corpus.extracted.ja | perl -CSD -Mutf8 -pe 's/(.)［[０-９．]+］$/${1}/;' > $data/raw/$corpus/$corpus.cleaned.ja
done

#######################################
# preprocessing baseline: train-1
#######################################

data_sub=$data/baseline
mkdir -p $data_sub

# link data sets

ln -snf $data/raw/dev/dev.extracted.en $data_sub/dev.en
ln -snf $data/raw/dev/dev.cleaned.ja $data_sub/dev.ja

ln -snf $data/raw/test/test.extracted.en $data_sub/test.en
ln -snf $data/raw/test/test.extracted.ja $data_sub/test.ja

# for baseline: only use train-1 as training data

ln -snf $data/raw/train/train-1.extracted.en $data_sub/train.en
ln -snf $data/raw/train/train-1.cleaned.ja $data_sub/train.ja


shared_models_sub=$shared_models/baseline
mkdir -p $shared_models_sub

sbatch --cpus-per-task=1 --time=00:30:00 --mem=16G --partition=hydra \
    $scripts/preprocess_generic.sh \
    $data_sub \
    $shared_models_sub \
    $basebase \
    $src \
    $trg \
    $bpe_total_symbols \
    $bpe_vocab_threshold

#######################################
# preprocessing train-1 and train-2
#######################################

data_sub=$data/noise1
mkdir -p $data_sub

# link data sets

ln -snf $data/raw/dev/dev.extracted.en $data_sub/dev.en
ln -snf $data/raw/dev/dev.cleaned.ja $data_sub/dev.ja

ln -snf $data/raw/test/test.extracted.en $data_sub/test.en
ln -snf $data/raw/test/test.extracted.ja $data_sub/test.ja

# for noise1 : use train-1 and train-2 as training data

cat $data/raw/train/train-1.extracted.en $data/raw/train/train-2.extracted.en > $data_sub/train.en
cat $data/raw/train/train-1.cleaned.ja $data/raw/train/train-2.cleaned.ja > $data_sub/train.ja

# do not train a new SP model: use baseline model for everything

shared_models_sub=$shared_models/baseline
mkdir -p $shared_models_sub

sbatch --cpus-per-task=1 --time=00:30:00 --mem=16G --partition=hydra \
    $scripts/preprocess_generic.sh \
    $data_sub \
    $shared_models_sub \
    $basebase \
    $src \
    $trg \
    $bpe_total_symbols \
    $bpe_vocab_threshold

#######################################
# preprocessing entire training data
#######################################

data_sub=$data/noise2
mkdir -p $data_sub

# link data sets

ln -snf $data/raw/dev/dev.extracted.en $data_sub/dev.en
ln -snf $data/raw/dev/dev.cleaned.ja $data_sub/dev.ja

ln -snf $data/raw/test/test.extracted.en $data_sub/test.en
ln -snf $data/raw/test/test.extracted.ja $data_sub/test.ja

# for noise2 : use train-1 and train-2 and train-3 as training data

cat $data/raw/train/train-1.extracted.en $data/raw/train/train-2.extracted.en $data/raw/train/train-3.extracted.en > $data_sub/train.en
cat $data/raw/train/train-1.cleaned.ja $data/raw/train/train-2.cleaned.ja $data/raw/train/train-3.cleaned.ja > $data_sub/train.ja

# do not train a new SP model: use baseline model for everything

shared_models_sub=$shared_models/baseline
mkdir -p $shared_models_sub

sbatch --cpus-per-task=1 --time=00:30:00 --mem=16G --partition=hydra \
    $scripts/preprocess_generic.sh \
    $data_sub \
    $shared_models_sub \
    $basebase \
    $src \
    $trg \
    $bpe_total_symbols \
    $bpe_vocab_threshold

#######################################
# noise1 only (without clean data)
#######################################

data_sub=$data/noise1-only
mkdir -p $data_sub

# link data sets

ln -snf $data/raw/dev/dev.extracted.en $data_sub/dev.en
ln -snf $data/raw/dev/dev.cleaned.ja $data_sub/dev.ja

ln -snf $data/raw/test/test.extracted.en $data_sub/test.en
ln -snf $data/raw/test/test.extracted.ja $data_sub/test.ja

# for noise1-only : use train-2 as training data

cat $data/raw/train/train-2.extracted.en > $data_sub/train.en
cat $data/raw/train/train-2.cleaned.ja > $data_sub/train.ja

# do not train a new SP model: use baseline model for everything

shared_models_sub=$shared_models/baseline
mkdir -p $shared_models_sub

sbatch --cpus-per-task=1 --time=00:30:00 --mem=16G --partition=hydra \
    $scripts/preprocess_generic.sh \
    $data_sub \
    $shared_models_sub \
    $basebase \
    $src \
    $trg \
    $bpe_total_symbols \
    $bpe_vocab_threshold

#######################################
# noise2 only (without clean data)
#######################################

data_sub=$data/noise2-only
mkdir -p $data_sub

# link data sets

ln -snf $data/raw/dev/dev.extracted.en $data_sub/dev.en
ln -snf $data/raw/dev/dev.cleaned.ja $data_sub/dev.ja

ln -snf $data/raw/test/test.extracted.en $data_sub/test.en
ln -snf $data/raw/test/test.extracted.ja $data_sub/test.ja

# for noise2-only : use train-2 and train-3 as training data

cat $data/raw/train/train-2.extracted.en $data/raw/train/train-3.extracted.en > $data_sub/train.en
cat $data/raw/train/train-2.cleaned.ja $data/raw/train/train-3.cleaned.ja > $data_sub/train.ja

# do not train a new SP model: use baseline model for everything

shared_models_sub=$shared_models/baseline
mkdir -p $shared_models_sub

sbatch --cpus-per-task=1 --time=00:30:00 --mem=16G --partition=hydra \
    $scripts/preprocess_generic.sh \
    $data_sub \
    $shared_models_sub \
    $basebase \
    $src \
    $trg \
    $bpe_total_symbols \
    $bpe_vocab_threshold
