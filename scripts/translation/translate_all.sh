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
translations=$base/translations

mkdir -p $translations

# custom translate for baseline without noise

data_sub=$data/baseline
translations_sub=$translations/baseline

mkdir -p $translations_sub

model_path=$models/baseline

sbatch --qos=vesta --time=1:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 3 --mem 48g $base/scripts/translation/translate_generic.sh $base $data_sub $translations_sub $model_path

# for now, only try for baseline, then exit

exit

for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do
  for noise_amount in 05 10 20 50 100; do

    echo "noise_type: $noise_type"
    echo "noise_amount: $noise_amount"

    data_sub=$data/$noise_type.$noise_amount
    translations_sub=$translations/$noise_type.$noise_amount

    if [[ -d $translations_sub ]]; then
        echo "Folder exists: $translations_sub"
        echo "Skipping."
        continue
    fi

    mkdir -p $translations_sub

    sbatch --qos=vesta --time=1:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 3 --mem 48g $base/scripts/translation/translate_generic.sh $base $data_sub $translations_sub $model_path
  done
done
