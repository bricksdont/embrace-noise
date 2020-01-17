#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

src=de
trg=en

data=$base/data
prepared=$data/prepared

mkdir -p $prepared

for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do
  for noise_amount in 05 10 20 50 100; do

    echo "noise_type: $noise_type"
    echo "noise_amount: $noise_amount"

    data_sub=$data/$noise_type.$noise_amount
    prepared_sub=$prepared/$noise_type.$noise_amount

    if [[ -d $prepared_sub ]]; then
        echo "Folder exists: $prepared_sub"
        echo "Skipping."
        continue
    fi

    mkdir -p $prepared_sub

    sbatch --cpus-per-task=4 --time=12:00:00 --mem=16G --partition=hydra $base/scripts/preprocessing/prepare_data_generic.sh $data_sub $prepared_sub
  done
done

# custom prepare for baseline without noise

data_sub=$data/baseline
prepared_sub=$prepared/baseline

mkdir -p $prepared_sub

sbatch --cpus-per-task=4 --time=12:00:00 --mem=16G --partition=hydra $base/scripts/preprocessing/prepare_data_generic.sh $data_sub $prepared_sub