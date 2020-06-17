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
  "noise2-only.filtered"
  "noise2-only.dcce.adq.0.25"
  "noise2-only.dcce.adq.0.5"
  "noise2-only.dcce.adq.0.75"
  "noise2-only.mined.score.0.25"
  "noise2-only.mined.score.0.5"
  "noise2-only.mined.score.0.75"
  "noise2-only.dcce.adq.instance_weighting"
  "noise2-only.dcce.adq.instance_weighting.exp0.1"
  "noise2-only.dcce.adq.instance_weighting.exp0.2"
  "noise2-only.dcce.adq.instance_weighting.exp0.3"
  "noise2-only.dcce.adq.instance_weighting.exp0.4"
  "noise2-only.dcce.adq.instance_weighting.exp0.5"
  "noise2-only.dcce.adq.instance_weighting.exp0.6"
  "noise2-only.dcce.adq.instance_weighting.exp0.7"
  "noise2-only.dcce.adq.instance_weighting.exp0.8"
  "noise2-only.dcce.adq.instance_weighting.exp0.9"
  "noise2-only.mined.score.instance_weighting"
  "noise2-only.mined.score.instance_weighting.exp1.25"
  "noise2-only.mined.score.instance_weighting.exp1.5"
  "noise2-only.mined.score.instance_weighting.exp1.75"
  "noise2-only.mined.score.instance_weighting.exp2.0"
  "noise2-only.mined.score.instance_weighting.exp2.25"
  "noise2-only.mined.score.instance_weighting.exp2.5"
  "noise2-only.mined.score.instance_weighting.exp2.75"
  "noise2-only.mined.score.instance_weighting.exp3.0"
  "noise2-only.filtered.token_weighting.exp0.05.geomean"
  "noise2-only.filtered.token_weighting.exp0.1.geomean"
  "noise2-only.filtered.token_weighting.exp0.2.geomean"
  "noise2-only.filtered.token_weighting.exp0.3.geomean"
  "noise2-only.filtered.token_weighting.exp0.4.geomean"
  "noise2-only.filtered.token_weighting.exp0.5.geomean"
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

    mode="bpe"

    sbatch --qos=vesta --time=00:12:00 --gres gpu:Tesla-V100-32GB:1 --cpus-per-task 1 --mem 16g \
        $basebase/scripts/aspec/scripts/translate_generic.sh \
            $basebase $data_sub $translations_sub $models_sub $src $trg $mode

done
