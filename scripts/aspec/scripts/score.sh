#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $basebase/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

src=en
trg=ja

scripts=$basebase/scripts
filtered=$base/filtered
models=$base/models

scores=$base/scores

mkdir -p $scores

# try larger batch size with 32GB V100

batch_size=1024
max_seq_len=128
score_type="neglogprob"

# basic approach: score all filtered data sets

# subset of data sets that should be scored

SCORE_SUBSET=(
  "noise2-only"
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

for filtered_sub in $filtered/noise2-only; do

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

    sbatch --qos=vesta --time=12:00:00 --gres gpu:Tesla-V100-32GB:1 --cpus-per-task 1 --mem 16g \
        $scripts/scoring/score_generic.sh $input_src $input_trg $output $batch_size $model_path $max_seq_len $score_type

    # backward scoring

    model_path=$models/baseline.reverse

    input_src=$filtered_sub/train.bpe.$trg
    input_trg=$filtered_sub/train.bpe.$src

    output=$scores_sub/scores.nmt.backward

    sbatch --qos=vesta --time=12:00:00 --gres gpu:Tesla-V100-32GB:1 --cpus-per-task 1 --mem 16g \
        $scripts/scoring/score_generic.sh $input_src $input_trg $output $batch_size $model_path $max_seq_len $score_type

done
