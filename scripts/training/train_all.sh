#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

src=de
trg=en

data=$base/data
prepared=$data/prepared
models=$base/models

mkdir -p models

# custom prepare for baseline without noise

data_sub=$data/baseline
prepared_sub=$prepared/baseline
model_path=$models/baseline

mkdir -p $model_path

sbatch --qos=vesta --time=72:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 3 --mem 48g $base/scripts/training/train_transformer_generic.sh $prepared_sub $data_sub $model_path

exit 0

for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do
  for noise_amount in 05 10 20 50 100; do

    echo "noise_type: $noise_type"
    echo "noise_amount: $noise_amount"

    data_sub=$data/$noise_type.$noise_amount
    prepared_sub=$prepared/$noise_type.$noise_amount
    model_path=$models/$noise_type.$noise_amount

    if [[ -d $model_path ]]; then
        echo "Folder exists: $model_path"
        echo "Skipping."
        continue
    fi

    mkdir -p $model_path

    sbatch --qos=vesta --time=72:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 3 --mem 48g $base/scripts/training/train_transformer_generic.sh $prepared_sub $data_sub $model_path
  done
done
