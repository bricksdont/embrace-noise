#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/laser3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

src=de
trg=en

tools=$base/tools
data=$base/data
scripts=$base/scripts
filtered=$base/filtered

MOSES=$base/tools/moses-scripts/scripts

LASER=$tools/laser

model_dir="${LASER}/models"
encoder="${model_dir}/bilstm.93langs.2018-12-26.pt"
bpe_codes="${model_dir}/93langs.fcodes"

embedded=$base/embedded

mkdir -p $embedded

EMBED_SUBSET=(
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

  embedded_sub=$embedded/$name

  if [ $(contains "${EMBED_SUBSET[@]}" $name) == "n" ]; then
      echo "name: $name not in subset that should be embedded"
      echo "Skipping."
      continue
  fi

  mkdir -p $embedded_sub

  for lang in $src $trg; do

      if [[ ! -f $filtered_sub/train.$lang ]]; then
        # detokenize data (LASER has its own specific tokenization)

        cat $filtered_sub/train.tok.$lang | $MOSES/tokenizer/detokenizer.perl -l $lang > $filtered_sub/train.$lang
      fi

      raw_file=$filtered_sub/train.$lang
      embedded_file=$embedded_sub/train.embedded.$lang

      if [[ -f $embedded_file ]]; then
        echo "Embeddings exist: $embedded_file"
        echo "Skipping."
        continue
      fi
      sbatch --qos=vesta --time=06:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 1 --mem 16g $scripts/mining/embed_generic.sh $LASER $encoder $bpe_codes $raw_file $embedded_file $lang
  done
done
