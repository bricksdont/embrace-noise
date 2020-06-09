#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load generic

src=de
trg=en

data=$base/data

fast_align=$base/fast_align

mkdir -p $fast_align

for model_name in baseline raw_paracrawl.100 raw_paracrawl.100.filtered; do

    data_sub=$data/$model_name

    echo "data_sub: $data_sub"

    # forward model

    fast_align_sub=$fast_align/$model_name

    if [[ -d $fast_align_sub ]]; then
        echo "Folder exists: $fast_align_sub"
        echo "Skipping."
        continue
    fi

    mkdir -p $fast_align_sub

    if [[ ! -s $fast_align_sub/input.raw ]]; then
        perl $base/tools/paste-files.pl $data_sub/train.bpe.$src $data_sub/train.bpe.$trg > $fast_align_sub/input.raw
    fi

    if [[ ! -s $fast_align_sub/input ]]; then
        perl $base/tools/filter-length.pl -200 $fast_align_sub/input.raw > $fast_align_sub/input
    fi

    sbatch --cpus-per-task=32 --time=02:00:00 --mem=32G --partition=generic $base/scripts/fast_align/train_fast_align_model_generic.sh $base $fast_align_sub ""

    # reverse model

    fast_align_sub=$fast_align/"$model_name"_reverse

    if [[ -d $fast_align_sub ]]; then
        echo "Folder exists: $fast_align_sub"
        echo "Skipping."
    fi

    mkdir -p $fast_align_sub

    ln -snf $fast_align/$model_name/input $fast_align/"$model_name"_reverse/input

    sbatch --cpus-per-task=32 --time=02:00:00 --mem=32G --partition=generic $base/scripts/fast_align/train_fast_align_model_generic.sh $base $fast_align_sub "-r"

done

# train with tokenized instead of BPE

for original_model_name in baseline raw_paracrawl.100 raw_paracrawl.100.filtered raw_paracrawl.100.dcce.adq.0.75 raw_paracrawl.100.mined.score.0.75; do

    data_sub=$data/$original_model_name

    echo "data_sub (but will be tokenized): $data_sub"

    # forward model
    model_name=$original_model_name.word_level

    fast_align_sub=$fast_align/$model_name

    if [[ -d $fast_align_sub ]]; then
        echo "Folder exists: $fast_align_sub"
        echo "Skipping."
        continue
    fi

    mkdir -p $fast_align_sub

    if [[ ! -s $fast_align_sub/input.raw ]]; then
        cat $data_sub/train.bpe.$src | sed -r 's/@@( |$)//g' > $fast_align_sub/train.tok.$src
        cat $data_sub/train.bpe.$trg | sed -r 's/@@( |$)//g' > $fast_align_sub/train.tok.$trg
        perl $base/tools/paste-files.pl $fast_align_sub/train.tok.$src $fast_align_sub/train.tok.$trg > $fast_align_sub/input.raw
    fi

    if [[ ! -s $fast_align_sub/input ]]; then
        perl $base/tools/filter-length.pl -200 $fast_align_sub/input.raw > $fast_align_sub/input
    fi

    sbatch --cpus-per-task=32 --time=02:00:00 --mem=32G --partition=generic $base/scripts/fast_align/train_fast_align_model_generic.sh $base $fast_align_sub ""

    # reverse model

    fast_align_sub=$fast_align/"$model_name"_reverse

    if [[ -d $fast_align_sub ]]; then
        echo "Folder exists: $fast_align_sub"
        echo "Skipping."
    fi

    mkdir -p $fast_align_sub

    ln -snf $fast_align/$model_name/input $fast_align/"$model_name"_reverse/input

    sbatch --cpus-per-task=32 --time=02:00:00 --mem=32G --partition=generic $base/scripts/fast_align/train_fast_align_model_generic.sh $base $fast_align_sub "-r"

done
