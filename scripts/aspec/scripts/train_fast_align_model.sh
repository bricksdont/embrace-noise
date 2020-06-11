#! /bin/bash


base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $basebase/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hpc

src=en
trg=ja

data=$base/data

fast_align=$base/fast_align

mkdir -p $fast_align

# train with tokenized instead of BPE

for original_model_name in noise2-only.filtered; do

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
        perl $basebase/tools/paste-files.pl $fast_align_sub/train.tok.$src $fast_align_sub/train.tok.$trg > $fast_align_sub/input.raw 2> $fast_align_sub/paste.err
    fi

    if [[ ! -s $fast_align_sub/input ]]; then
        perl $basebase/tools/filter-length.pl -200 $fast_align_sub/input.raw > $fast_align_sub/input 2> $fast_align_sub/filter.err
    fi

    sbatch --cpus-per-task=32 --time=02:00:00 --mem=32G --partition=hpc $basebase/scripts/fast_align/train_fast_align_model_generic.sh $basebase $fast_align_sub ""

    # reverse model

    fast_align_sub=$fast_align/"$model_name"_reverse

    if [[ -d $fast_align_sub ]]; then
        echo "Folder exists: $fast_align_sub"
        echo "Skipping."
    fi

    mkdir -p $fast_align_sub

    ln -snf $fast_align/$model_name/input $fast_align/"$model_name"_reverse/input

    sbatch --cpus-per-task=32 --time=02:00:00 --mem=32G --partition=hpc $basebase/scripts/fast_align/train_fast_align_model_generic.sh $basebase $fast_align_sub "-r"

done
