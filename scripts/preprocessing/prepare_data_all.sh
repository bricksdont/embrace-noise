#! /bin/bash

# work around slurm placing scripts in var folder
if [[ $1 == "mode=sbatch" ]]; then
  base=/net/cephfs/home/mathmu/scratch/noise-distill
else
  script_dir=`dirname "$0"`
  base=$script_dir/../..
fi;

src=de
trg=en

for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do
  for noise_amount in 05 10 20 50 100; do
    . $base/scripts/preprocessing/prepare_data_generic.sh
  done
done

# custom prepare for baseline without noise

prepare_baseline=$base/data/prepare/baseline

mkdir -p $prepare_baseline

python -m sockeye.prepare_data \
                        -s $data/train/raw/baseline.tok.$src \
                        -t $data/train/raw/baseline.tok.$trg \
			                  --shared-vocab \
                        -o $prepared_individual
