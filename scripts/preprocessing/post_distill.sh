#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

src=de
trg=en

data=$base/data
distilled=$base/distilled

# baseline distill data

distill_sub=$distilled/baseline_distilled
data_sub=$data/baseline_distilled

mkdir -p $data_sub

cat $data/baseline/train.bpe.$src $distill_sub/train.bpe.$src > $data_sub/train.bpe.$src
cat $data/baseline/train.bpe.$trg $distill_sub/train.bpe.$trg > $data_sub/train.bpe.$trg

# baseline data combined with noise

for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do
  for noise_amount in 05 10 20 50 100; do

    echo "noise_type: $noise_type"
    echo "noise_amount: $noise_amount"

    distill_sub=$distilled/$noise_type.$noise_amount
    data_sub=$data/$noise_type"_distilled".$noise_amount

    if [[ -d $data_sub ]]; then
        echo "Folder exists: $data_sub"
        echo "Skipping."
        continue
    fi

    mkdir -p $data_sub

    cat $data/baseline/train.bpe.$src $distill_sub/train.bpe.$src > $data_sub/train.bpe.$src
    cat $data/baseline/train.bpe.$trg $distill_sub/train.bpe.$trg > $data_sub/train.bpe.$trg

  done
done
