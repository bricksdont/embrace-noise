#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $basebase/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

src=en
trg=ja

data=$base/data
filtered=$base/filtered

scripts=$basebase/scripts
tools=$basebase/tools

mkdir -p $filtered

for data_sub in $data/*; do

    echo "data_sub: $data_sub"

    name=$(basename $data_sub)

    filter_sub=$filtered/$name

    if [[ -d $filter_sub ]]; then
        echo "Folder exists: $filter_sub"
        echo "Skipping."
        continue
    fi

    mkdir -p $filter_sub

    input_src=$data_sub/train.pieces.$src
    input_trg=$data_sub/train.pieces.$trg

    output_src=$filter_sub/train.pieces.$src
    output_trg=$filter_sub/train.pieces.$trg

    logfile=$filter_sub/log
    rules="overlap min-length max-length"

    . $scripts/preprocessing/filter_generic.sh 2>&1 | tee -a $logfile
done

echo "Size of all files:"
wc -l $filtered/*/*
