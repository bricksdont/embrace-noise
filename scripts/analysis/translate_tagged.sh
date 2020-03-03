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
translations=$base/analysis/translations_tagged

mkdir -p $translations

# subset of models for translation

TRANSLATE_SUBSET=(
  "raw_paracrawl.100.tagged"
  "raw_paracrawl.100.filtered.tagged"
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

# create tagged version of dev and test set from baseline (all other data folders link there)

for corpus in dev test; do
    for lang in $src $trg; do
        if [[ ! -f $data/baseline/$corpus.tag.$lang ]]; then
            cat $data/baseline/$corpus.bpe.$lang | python $scripts/preprocessing/add_tag_to_lines.py --tag "<N>" > $data/baseline/$corpus.tag.$lang
        fi
    done
done

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

    for corpus in dev test; do
        for lang in $src $trg; do
            ln -snf $data/baseline/$corpus.tag.$lang $data_sub/$corpus.tag.$lang
        done
    done

    sbatch --qos=vesta --time=00:10:00 --gres gpu:Tesla-V100:1 --cpus-per-task 3 --mem 48g $base/scripts/translation/translate_tagged_generic.sh $base $data_sub $translations_sub $models_sub

done
