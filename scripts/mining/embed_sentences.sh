#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/laser3/bin/activate

src=de
trg=en

tools=$base/tools
data=$base/data
scripts=$base/scripts
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

  for lang in $src $trg; do

    raw_file=
  done
done

languages=("de" "en" "fr" "it")

raw_prefix="cs-bulletin"
embedded_prefix="cs-bulletin.embeddings"

for language in ${languages[@]} ; do
    raw_file=$data/$raw_prefix.$language
    embedded_file=$embedded/$embedded_prefix.$language
    if [[ -f $embedded_file ]]; then
      echo "Embeddings exist: $embedded_file"
      echo "Skipping."
      continue
    fi
    sbatch --qos=vesta --time=01:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 3 --mem 48g $scripts/laser/embed_generic.sh $LASER $encoder $bpe_codes $raw_file $embedded_file $language

done

