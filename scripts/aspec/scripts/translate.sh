#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $basebase/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

data=$base/data
models=$base/models
translations=$base/translations

mkdir -p $translations

# subset of models for translation

TRANSLATE_SUBSET=(
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

for models_sub in $models/*; do

    echo "models_sub: $models_sub"

    name=$(basename $models_sub)

    if [[ $name == "baseline.reverse" ]]; then
        src=ja
        trg=en
    else
        src=en
        trg=ja
    fi

    data_sub=$data/$name
    translations_sub=$translations/$name

    if [[ -d $translations_sub ]]; then
        echo "Folder exists: $translations_sub"
        echo "Skipping."
        continue
    fi

    if [ $(contains "${TRANSLATE_SUBSET[@]}" $name) == "n" ]; then
        echo "name: $name not in subset that should be translated"
        echo "Skipping."
        continue
    fi

    training_finished=`grep "Training finished" $models_sub/log | wc -l`

    if [[ $training_finished == 0 ]]; then
        echo "Training not finished"
        echo "Skipping."
        continue
    fi

    mkdir -p $translations_sub

    sbatch --qos=vesta --time=00:12:00 --gres gpu:Tesla-V100-32GB:1 --cpus-per-task 1 --mem 16g \
        $base/scripts/translate_generic.sh \
            $base $data_sub $translations_sub $models_sub $src $trg

done
