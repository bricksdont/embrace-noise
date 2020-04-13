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
  "raw_paracrawl.100.tagged"
  "raw_paracrawl.100.filtered"
  "raw_paracrawl.100.filtered.tagged"
  "raw_paracrawl.100.distilled"
  "raw_paracrawl.100.dcce.adq.0.25"
  "raw_paracrawl.100.dcce.adq-dom.0.25"
  "raw_paracrawl.100.dcce.adq-dom.0.5"
  "raw_paracrawl.100.dcce.adq-dom.0.75"
  "raw_paracrawl.100.mined.mine.0.25"
  "raw_paracrawl.100.mined.mine.0.5"
  "raw_paracrawl.100.mined.mine.0.75"
  "raw_paracrawl.100.mined.score.0.25"
  "raw_paracrawl.100.mined.score.instance_weighting"
  "raw_paracrawl.100.dcce.adq.instance_weighting"
  "raw_paracrawl.100.dcce.adq-dom.instance_weighting"
  "raw_paracrawl.100.dcce.adq.instance_weighting.exp0.1"
  "raw_paracrawl.100.dcce.adq.instance_weighting.exp0.2"
  "raw_paracrawl.100.dcce.adq.instance_weighting.exp0.3"
  "raw_paracrawl.100.dcce.adq.instance_weighting.exp0.4"
  "raw_paracrawl.100.dcce.adq.instance_weighting.exp0.5"
  "raw_paracrawl.100.dcce.adq.instance_weighting.exp0.6"
  "raw_paracrawl.100.dcce.adq.instance_weighting.exp0.7"
  "raw_paracrawl.100.dcce.adq.instance_weighting.exp0.8"
  "raw_paracrawl.100.dcce.adq.instance_weighting.exp0.9"
  "raw_paracrawl.100.mined.score.instance_weighting.exp1.5"
  "raw_paracrawl.100.mined.score.instance_weighting.exp1.75"
  "raw_paracrawl.100.mined.score.instance_weighting.exp2.0"
  "raw_paracrawl.100.mined.score.instance_weighting.exp2.25"
  "raw_paracrawl.100.mined.score.instance_weighting.exp2.5"
  "raw_paracrawl.100.mined.score.instance_weighting.exp2.75"
  "raw_paracrawl.100.mined.score.instance_weighting.exp3.0"
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

    sbatch --qos=vesta --time=00:12:00 --gres gpu:Tesla-V100-32GB:1 --cpus-per-task 1 --mem 16g $base/scripts/translation/translate_generic.sh $base $data_sub $translations_sub $models_sub

done
