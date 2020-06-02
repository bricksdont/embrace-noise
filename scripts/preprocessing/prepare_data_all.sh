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
)

PREPARE_INSTANCE_WEIGHTING_SUBSET=(
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
)

PREPARE_TOKEN_WEIGHTING_SUBSET=(
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
    name=$(basename $data_sub)

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

    sbatch --cpus-per-task=1 --time=12:00:00 --mem=16G --partition=hpc $base/scripts/preprocessing/prepare_data_generic.sh $data_sub $prepared_sub

done

deactivate

source $base/venvs/sockeye3-custom-cpu/bin/activate

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

    instance_weighting_type="sentence"

    sbatch --cpus-per-task=1 --time=12:00:00 --mem=16G --partition=hpc $base/scripts/preprocessing/prepare_data_instance_weighting_generic.sh $data_sub $prepared_sub $instance_weighting_type

done

for data_sub in $data/*token_weighting*; do

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

    instance_weighting_type="word"

    sbatch --cpus-per-task=1 --time=12:00:00 --mem=16G --partition=hpc $base/scripts/preprocessing/prepare_data_instance_weighting_generic.sh $data_sub $prepared_sub $instance_weighting_type

done

