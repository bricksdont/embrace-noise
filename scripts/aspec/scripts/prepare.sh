#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $basebase/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

data=$base/data
prepared=$base/prepared

mkdir -p $prepared


# subset of models that should be prepared

PREPARE_SUBSET=(
  "baseline"
  "baseline.reverse"
  "noise1"
  "noise2"
)

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

# create baseline.reverse if does not exist

if [[ ! -d $data/baseline.reverse ]]; then
    cp -r $data/baseline $data/baseline.reverse
fi

for data_sub in $data/*; do

    echo "data_sub: $data_sub"
    name=$(basename $data_sub)

    if [[ $name == "baseline.reverse" ]]; then
        src=ja
        trg=en
    else
        src=en
        trg=ja
    fi

    prepared_sub=$prepared/$name

    if [[ -d $prepared_sub ]]; then
        echo "Folder exists: $prepared_sub"
        echo "Skipping."
        continue
    fi

    if [ $(contains "${PREPARE_SUBSET[@]}" $name) == "n" ]; then
        echo "name: $name not in subset that should be prepared"
        echo "Skipping."
        continue
    fi

    mkdir -p $prepared_sub

    mode=pieces

    sbatch --cpus-per-task=1 --time=12:00:00 --mem=16G --partition=hydra \
        $basebase/scripts/preprocessing/prepare_data_generic.sh \
            $data_sub $prepared_sub $src $trg $mode

done
