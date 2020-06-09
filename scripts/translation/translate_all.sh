#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3/bin/activate
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
  "baseline.filtered"
  "baseline.distilled"
  "raw_paracrawl.100"
  "raw_paracrawl.100.tagged"
  "raw_paracrawl.100.filtered"
  "raw_paracrawl.100.filtered.tagged"
  "raw_paracrawl.100.distilled"
  "raw_paracrawl.100.dcce.adq.0.25"
  "raw_paracrawl.100.dcce.adq.0.5"
  "raw_paracrawl.100.dcce.adq.0.75"
  "raw_paracrawl.100.dcce.adq-dom.0.25"
  "raw_paracrawl.100.dcce.adq-dom.0.5"
  "raw_paracrawl.100.dcce.adq-dom.0.75"
  "raw_paracrawl.100.mined.mine.0.25"
  "raw_paracrawl.100.mined.mine.0.5"
  "raw_paracrawl.100.mined.mine.0.75"
  "raw_paracrawl.100.mined.score.0.25"
  "raw_paracrawl.100.mined.score.0.5"
  "raw_paracrawl.100.mined.score.0.75"
  "raw_paracrawl.100.modelfront.0.25"
  "raw_paracrawl.100.modelfront.0.5"
  "raw_paracrawl.100.modelfront.0.75"
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
  "baseline.filtered.weight_ones"
  "raw_paracrawl.100.weight_ones"
  "raw_paracrawl.100.filtered.tagged.weight_ones"
  "raw_paracrawl.100.mined.score.0.25.weight_ones"
  "raw_paracrawl.100.mined.score.instance_weighting.weight_ones"
  "raw_paracrawl.100.dcce.adq.0.25.weight_ones"
  "raw_paracrawl.100.dcce.adq.instance_weighting.weight_ones"
  "raw_paracrawl.100.filtered.token_weighting.exp0.05.geomean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.1.geomean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.15.geomean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.2.geomean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.25.geomean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.3.geomean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.35.geomean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.4.geomean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.6.geomean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.8.geomean"
  "raw_paracrawl.100.filtered.token_weighting.exp1.0.geomean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.05.mean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.1.mean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.15.mean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.2.mean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.25.mean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.3.mean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.35.mean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.4.mean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.6.mean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.8.mean"
  "raw_paracrawl.100.filtered.token_weighting.exp1.0.mean"
  "raw_paracrawl.100.filtered.token_weighting.exp0.05.max"
  "raw_paracrawl.100.filtered.token_weighting.exp0.1.max"
  "raw_paracrawl.100.filtered.token_weighting.exp0.15.max"
  "raw_paracrawl.100.filtered.token_weighting.exp0.2.max"
  "raw_paracrawl.100.filtered.token_weighting.exp0.25.max"
  "raw_paracrawl.100.filtered.token_weighting.exp0.3.max"
  "raw_paracrawl.100.filtered.token_weighting.exp0.35.max"
  "raw_paracrawl.100.filtered.token_weighting.exp0.4.max"
  "raw_paracrawl.100.filtered.token_weighting.exp0.6.max"
  "raw_paracrawl.100.filtered.token_weighting.exp0.8.max"
  "raw_paracrawl.100.filtered.token_weighting.exp1.0.max"
  "raw_paracrawl.100.filtered.token_weighting.trust_clean.exp0.1.geomean"
  "raw_paracrawl.100.filtered.token_weighting.trust_clean.exp0.2.geomean"
  "raw_paracrawl.100.filtered.token_weighting.trust_clean.exp0.3.geomean"
  "raw_paracrawl.100.filtered.token_weighting.trust_clean.exp0.4.geomean"
  "raw_paracrawl.100.filtered.token_weighting.trust_clean.exp0.5.geomean"
  "raw_paracrawl.100.filtered.token_weighting.trust_clean.exp0.6.geomean"
  "raw_paracrawl.100.filtered.token_weighting.trust_clean.exp0.7.geomean"
  "raw_paracrawl.100.filtered.token_weighting.trust_clean.exp0.8.geomean"
  "raw_paracrawl.100.filtered.token_weighting.trust_clean.exp0.9.geomean"
  "raw_paracrawl.100.filtered.token_weighting.trust_clean.exp1.0.geomean"
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
        src=en
        trg=de
    else
        src=de
        trg=en
    fi

    data_sub=$data/$name
    translations_sub=$translations/$name

    if [[ -d $translations_sub ]]; then
        echo "Folder exists: $translations_sub"
        echo "Skipping."
        continue
    fi

    if [[ ! -d $models_sub ]]; then
        echo "Folder does not exist: $models_sub"
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
        $base/scripts/translation/translate_generic.sh \
            $base $data_sub $translations_sub $models_sub $src $trg

done
