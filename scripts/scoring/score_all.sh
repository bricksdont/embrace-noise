#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

src=de
trg=en

scripts=$base/scripts
filtered=$base/filtered
models=$base/models

scores=$base/scores

mkdir -p $scores

batch_size=512
max_seq_len=128

# basic approach: score all filtered data sets

# subset of data sets that should be scored

SCORE_SUBSET=(
  "raw_paracrawl.100"
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

for filtered_sub in $filtered/*; do

    echo "filtered_sub: $filtered_sub"

    name=$(basename $filtered_sub)

    scores_sub=$scores/$name

    if [[ -d $scores_sub ]]; then
        echo "Folder exists: $scores_sub"
        echo "Skipping."
        continue
    fi

    if [ $(contains "${SCORE_SUBSET[@]}" $name) == "n" ]; then
        echo "name: $name not in subset that should be scored"
        echo "Skipping."
        continue
    fi

    mkdir -p $scores_sub

    # forward scoring

    model_path=$models/baseline

    input_src=$filtered_sub/train.bpe.$src
    input_trg=$filtered_sub/train.bpe.$trg

    output=$scores_sub/scores.nmt.forward

    sbatch --qos=vesta --time=12:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 1 --mem 16g $base/scripts/scoring/score_generic.sh $input_src $input_trg $output $batch_size $model_path $max_seq_len

    # backward scoring

    model_path=$models/baseline.reverse

    input_src=$filtered_sub/train.bpe.$trg
    input_trg=$filtered_sub/train.bpe.$src

    output=$scores_sub/scores.nmt.backward

    sbatch --qos=vesta --time=12:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 1 --mem 16g $base/scripts/scoring/score_generic.sh $input_src $input_trg $output $batch_size $model_path $max_seq_len

done
