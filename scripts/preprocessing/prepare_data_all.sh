#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

src=de
trg=en

data=$base/data
prepared=$base/prepared

mkdir -p $prepared

# subset of models that should be prepared

PREPARE_SUBSET=(
  "baseline"
  "baseline.reverse"
  "baseline.filtered"
  "baseline.distilled"
  "raw_paracrawl.100"
  "raw_paracrawl.100.filtered"
  "raw_paracrawl.100.distilled"
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

for data_sub in $data/*; do

    echo "data_sub: $data_sub"
    name=$(basename $prepared_sub)

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

    sbatch --cpus-per-task=1 --time=12:00:00 --mem=16G --partition=hydra $base/scripts/preprocessing/prepare_data_generic.sh $data_sub $prepared_sub
  done
done
