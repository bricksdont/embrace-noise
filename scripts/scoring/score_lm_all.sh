#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/laser3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

trg=en

scripts=$base/scripts
filtered=$base/filtered
models_lm=$base/models_lm

scores_lm=$base/scores_lm

mkdir -p $scores_lm

score_type="neglogprob"

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

    scores_lm_sub=$scores_lm/$name

    if [[ -d $scores_lm_sub ]]; then
        echo "Folder exists: $scores_lm_sub"
        echo "Skipping."
        continue
    fi

    if [ $(contains "${SCORE_SUBSET[@]}" $name) == "n" ]; then
        echo "name: $name not in subset that should be scored"
        echo "Skipping."
        continue
    fi

    mkdir -p $scores_lm_sub

    # LM in-domain scoring

    model_path=$models_lm/baseline

    input=$filtered_sub/train.bpe.$trg
    output=$scores_lm_sub/scores.lm.indomain

    sbatch --qos=vesta --time=12:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 1 --mem 16g $base/scripts/scoring/score_lm_generic.sh $input $output $model_path $score_type $scripts

    # LM out-of-domain scoring

    model_path=$models_lm/raw_paracrawl.100

    input=$filtered_sub/train.bpe.$trg
    output=$scores_lm_sub/scores.lm.outdomain

    sbatch --qos=vesta --time=12:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 1 --mem 16g $base/scripts/scoring/score_lm_generic.sh $input $output $model_path $score_type $scripts

done
