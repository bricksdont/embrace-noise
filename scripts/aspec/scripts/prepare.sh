#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $basebase/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load generic

data=$base/data
prepared=$base/prepared

mkdir -p $prepared


# subset of models that should be prepared

PREPARE_SUBSET=(
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

PREPARE_INSTANCE_WEIGHTING_SUBSET=(
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

PREPARE_TOKEN_WEIGHTING_SUBSET=(
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

    mode=bpe

    sbatch --cpus-per-task=1 --time=12:00:00 --mem=16G --partition=generic \
        $basebase/scripts/preprocessing/prepare_data_generic.sh \
            $data_sub $prepared_sub $src $trg $mode

done

deactivate

source $basebase/venvs/sockeye3-custom-cpu/bin/activate

src=en
trg=ja

for data_sub in $data/*; do

    echo "data_sub: $data_sub"
    name=$(basename $data_sub)

    prepared_sub=$prepared/$name

    if [[ -d $prepared_sub ]]; then
        echo "Folder exists: $prepared_sub"
        echo "Skipping."
        continue
    fi

    if [ $(contains "${PREPARE_INSTANCE_WEIGHTING_SUBSET[@]}" $name) == "n" ]; then
        echo "name: $name not in subset that should be prepared"
        echo "Skipping."
        continue
    fi

    mkdir -p $prepared_sub

    mode=bpe
    instance_weighting_type="sentence"

    sbatch --cpus-per-task=1 --time=12:00:00 --mem=16G --partition=generic \
        $basebase/scripts/preprocessing/prepare_data_instance_weighting_generic.sh \
            $data_sub $prepared_sub $instance_weighting_type $src $trg $mode

done

for data_sub in $data/*; do

    echo "data_sub: $data_sub"
    name=$(basename $data_sub)

    prepared_sub=$prepared/$name

    if [[ -d $prepared_sub ]]; then
        echo "Folder exists: $prepared_sub"
        echo "Skipping."
        continue
    fi

    if [ $(contains "${PREPARE_TOKEN_WEIGHTING_SUBSET[@]}" $name) == "n" ]; then
        echo "name: $name not in subset that should be prepared"
        echo "Skipping."
        continue
    fi

    mkdir -p $prepared_sub

    mode=bpe
    instance_weighting_type="word"

    sbatch --cpus-per-task=1 --time=12:00:00 --mem=16G --partition=generic \
        $basebase/scripts/preprocessing/prepare_data_instance_weighting_generic.sh \
            $data_sub $prepared_sub $instance_weighting_type $src $trg $mode

done
