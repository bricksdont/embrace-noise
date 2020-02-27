#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

src=de
trg=en

data=$base/data
prepared=$base/prepared
models=$base/models

mkdir -p models

# subset of models that should be trained

TRAIN_SUBSET=(
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

    sbatch --qos=vesta --time=72:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 1 --mem 16g $base/scripts/training/train_transformer_generic.sh $prepared_sub $data_sub $model_path
done
