#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

src=de
trg=en

data=$base/data
models=$base/models
translations=$base/translations

mkdir -p $translations

# subset of models for translation

TRANSLATE_SUBSET=(
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

for models_sub in $models/*; do

    echo "models_sub: $models_sub"

    name=$(basename $models_sub)

    data_sub=$data/$name
    translations_sub=$translations/$name

    if [[ -d $translations_sub ]]; then
        echo "Folder exists: $translations_sub"
        echo "Skipping."
        continue
    fi

    if [ $(contains "${TRANSLATE_SUBSET[@]}" $name) == "n" ]; then
        echo "name: $name not in subset that should be trained"
        echo "Skipping."
        continue
    fi

    mkdir -p $translations_sub

    sbatch --qos=vesta --time=00:10:00 --gres gpu:Tesla-V100:1 --cpus-per-task 3 --mem 48g $base/scripts/translation/translate_generic.sh $base $data_sub $translations_sub $models_sub

done
