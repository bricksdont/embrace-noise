#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $basebase/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

data=$base/data
prepared=$base/prepared
models=$base/models

mkdir -p models

# subset of models that should be trained

TRAIN_SUBSET=(
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
)

TRAIN_SUBSET_INSTANCE_WEIGHTING=(
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
)

TRAIN_SUBSET_TOKEN_WEIGHTING=(
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

for prepared_sub in $prepared/*; do

    echo "prepared_sub: $prepared_sub"

    name=$(basename $prepared_sub)

    if [[ $name == "baseline.reverse" ]]; then
        src=ja
        trg=en
    else
        src=en
        trg=ja
    fi

    data_sub=$data/$name
    model_path=$models/$name

    if [[ -d $model_path ]]; then
        echo "Folder exists: $model_path"

        training_finished=`grep "Training finished" $model_path/log | wc -l`

        if [[ $training_finished == 0 ]]; then
            echo "Training not finished"
            echo "Will continue training."
        else
            echo "Training is finished"
            echo "Skipping."
            continue
        fi
    fi

    if [ $(contains "${TRAIN_SUBSET[@]}" $name) == "n" ]; then
        echo "name: $name not in subset that should be trained"
        echo "Skipping."
        continue
    fi

    mkdir -p $model_path

    additional_args=""
    mode="bpe"

    sbatch --qos=vesta --time=72:00:00 --gres gpu:Tesla-V100-32GB:1 --cpus-per-task 1 --mem 16g \
        $basebase/scripts/training/train_transformer_generic.sh \
            $prepared_sub $data_sub $model_path "$additional_args" $src $trg $mode
done

deactivate
source $basebase/venvs/sockeye3-custom/bin/activate

echo "switched to custom Sockeye codebase"

src=en
trg=ja

for prepared_sub in $prepared/*; do

    echo "prepared_sub: $prepared_sub"

    name=$(basename $prepared_sub)

    data_sub=$data/$name
    model_path=$models/$name

    if [[ -d $model_path ]]; then
        echo "Folder exists: $model_path"

        training_finished=`grep "Training finished" $model_path/log | wc -l`

        if [[ $training_finished == 0 ]]; then
            echo "Training not finished"
            echo "Will continue training."
        else
            echo "Training is finished"
            echo "Skipping."
            continue
        fi
    fi

    if [ $(contains "${TRAIN_SUBSET_INSTANCE_WEIGHTING[@]}" $name) == "n" ]; then
        echo "name: $name not in subset that should be trained"
        echo "Skipping."
        continue
    fi

    mkdir -p $model_path

    additional_args=""
    mode="bpe"
    instance_weighting_type="sentence"

    sbatch --qos=vesta --time=72:00:00 --gres gpu:Tesla-V100-32GB:1 --cpus-per-task 1 --mem 16g \
        $basebase/scripts/training/train_transformer_instance_weighting_generic.sh \
            $prepared_sub $data_sub $model_path $instance_weighting_type "$additional_args" $src $trg $mode
done

for prepared_sub in $prepared/*token_weighting*; do

    echo "prepared_sub: $prepared_sub"

    name=$(basename $prepared_sub)

    data_sub=$data/$name
    model_path=$models/$name

    if [[ -d $model_path ]]; then
        echo "Folder exists: $model_path"

        training_finished=`grep "Training finished" $model_path/log | wc -l`

        if [[ $training_finished == 0 ]]; then
            echo "Training not finished"
            echo "Will continue training."
        else
            echo "Training is finished"
            echo "Skipping."
            continue
        fi
    fi

    if [ $(contains "${TRAIN_SUBSET_TOKEN_WEIGHTING[@]}" $name) == "n" ]; then
        echo "name: $name not in subset that should be trained"
        echo "Skipping."
        continue
    fi

    mkdir -p $model_path

    additional_args=""
    mode="bpe"
    instance_weighting_type="word"

    sbatch --qos=vesta --time=72:00:00 --gres gpu:Tesla-V100-32GB:1 --cpus-per-task 1 --mem 16g \
        $basebase/scripts/training/train_transformer_instance_weighting_generic.sh \
            $prepared_sub $data_sub $model_path $instance_weighting_type "$additional_args" $src $trg $mode
done
