#! /bin/bash

# work around slurm placing scripts in var folder
if [[ $1 == "mode=sbatch" ]]; then
  base=/net/cephfs/home/mathmu/scratch/noise-distill
else
  script_dir=`dirname "$0"`
  base=$script_dir/..
fi;

for noise_type in misaligned_sent, misordered_words_src, misordered_words_trg, wrong_lang_fr_src, wrong_lang_fr_trg, untranslated_en_src, untranslated_de_trg, short_max2, short_max5, raw_paracrawl; do
    . $base/scripts/preprocessing/preprocess_generic.sh
done
