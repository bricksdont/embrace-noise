#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/laser3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

src=en
trg=ja

scripts=$basebase/scripts

tools=$base/tools
data=$base/data
shared_models=$base/shared_models
filtered=$base/filtered

LASER=$tools/laser

model_dir="${LASER}/models"
encoder="${model_dir}/bilstm.93langs.2018-12-26.pt"
bpe_codes="${model_dir}/93langs.fcodes"

embedded=$base/embedded

mkdir -p $embedded

for filtered_sub in $filtered/*; do

  echo "filtered_sub: $filtered_sub"

  name=$(basename $filtered_sub)

  embedded_sub=$embedded/$name

  mkdir -p $embedded_sub

  for lang in $src $trg; do

      if [[ ! -f $filtered_sub/train.$lang ]]; then
        # remove pieces data (LASER has its own specific preprocessing)

        cat $filtered_sub/train.pieces.$lang | \
            python $base/scripts/remove_sentencepiece.py --model $shared_models/baseline/$src$trg.sentencepiece.model \
                > $filtered_sub/train.$lang
      fi

      raw_file=$filtered_sub/train.$lang
      embedded_file=$embedded_sub/train.embedded.$lang

      if [[ -f $embedded_file ]]; then
        echo "Embeddings exist: $embedded_file"
        echo "Skipping."
        continue
      fi
      sbatch --qos=vesta --time=06:00:00 --gres gpu:Tesla-V100-32GB:1 --cpus-per-task 1 --mem 16g \
          $scripts/mining/embed_generic.sh $LASER $encoder $bpe_codes $raw_file $embedded_file $lang
  done
done
