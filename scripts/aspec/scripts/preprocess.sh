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

sentencepiece_vocab_size=32000

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
# preprocessing baseline
#######################################

data_sub=$data/baseline
mkdir -p $data_sub

# link data sets

for corpus in dev test; do
    for lang in $src $trg; do
        ln -snf $data/raw/$corpus/$corpus.$lang $data_sub/$corpus.$lang
    done
done

# for baseline: only use train-1 as training data

for lang in $src $trg; do
    ln -snf $data/raw/train/train-1.$lang $data_sub/train.$lang
done

shared_models_sub=$shared_models/baseline
mkdir -p $shared_models_sub

sbatch --cpus-per-task=1 --time=00:30:00 --mem=4G --partition=hpc \
    $scripts/preprocess_generic.sh \
    $data_sub \
    $shared_models_sub \
    $scripts \
    $sentencepiece_vocab_size \
    $src \
    $trg

#######################################
# preprocessing train-1 and train-2
#######################################

data_sub=$data/noise1
mkdir -p $data_sub

# link data sets

for corpus in dev test; do
    for lang in $src $trg; do
        ln -snf $data/raw/$corpus/$corpus.$lang $data_sub/$corpus.$lang
    done
done

# for noise1: use train-1 and train-2 as training data

for lang in $src $trg; do
    cat $data/raw/train/train-1.$lang $data/raw/train/train-2.$lang > $data_sub/train.$lang
done

# do not train a new SP model: use baseline model for everything

shared_models_sub=$shared_models/baseline
mkdir -p $shared_models_sub

sbatch --cpus-per-task=1 --time=00:30:00 --mem=4G --partition=hpc \
    $scripts/preprocess_generic.sh \
    $data_sub \
    $shared_models_sub \
    $scripts \
    $sentencepiece_vocab_size \
    $src \
    $trg

#######################################
# preprocessing entire training data
#######################################

data_sub=$data/noise2
mkdir -p $data_sub

# link data sets

for corpus in dev test; do
    for lang in $src $trg; do
        ln -snf $data/raw/$corpus/$corpus.$lang $data_sub/$corpus.$lang
    done
done

# for noise2: use train-1 and train-2 as training data

for lang in $src $trg; do
    cat $data/raw/train/train-1.$lang $data/raw/train/train-2.$lang $data/raw/train/train-3.$lang > $data_sub/train.$lang
done

# do not train a new SP model: use baseline model for everything

shared_models_sub=$shared_models/baseline
mkdir -p $shared_models_sub

sbatch --cpus-per-task=1 --time=00:30:00 --mem=4G --partition=hpc \
    $scripts/preprocess_generic.sh \
    $data_sub \
    $shared_models_sub \
    $scripts \
    $sentencepiece_vocab_size \
    $src \
    $trg
