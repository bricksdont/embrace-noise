#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load volta cuda/10.0

src=de
trg=en

scripts=$base/scripts
data=$base/data
models=$base/models
shared_models=$base/shared_models
distilled=$base/distilled

mkdir -p $distilled

batch_size=64
chunk_size=25000

# distill baseline

data_sub=$data/baseline
distill_sub=$distilled/baseline_distilled

model_path=$models/baseline

distill_baseline=true

if [[ -d $distill_sub ]]; then
    echo "Folder exists: $distill_sub"
    if [[ -f $distill_sub/train.bpe.$trg ]]; then
      echo "Distilled train data exists: $distill_sub/train.bpe.$trg"

      num_lines_train_src=`cat $distill_sub/train.bpe.$src | wc -l`
      num_lines_train_trg=`cat $distill_sub/train.bpe.$trg | wc -l`

      if [[ $num_lines_train_src == $num_lines_train_trg ]]; then
        echo "Same number of lines in training source and target:"
        echo "$num_lines_train_src == $num_lines_train_trg"
        echo "Skipping."

        distill_baseline=false
      fi
    fi
fi

if [ "$distill_baseline" = true ]; then
    mkdir -p $distill_sub

    # link source side of training data

    ln -sfn $data_sub/train.bpe.$src $distill_sub/train.bpe.$src

    . $scripts/translation/decode_parallel_generic.sh &
fi

# subset of data sets that should be distilled

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

noise_types_subset=("raw_paracrawl")
noise_amounts_subset=("100")

for noise_type in misaligned_sent misordered_words_src misordered_words_trg wrong_lang_fr_src wrong_lang_fr_trg untranslated_en_src untranslated_de_trg short_max2 short_max5 raw_paracrawl; do
  for noise_amount in 05 10 20 50 100; do

    echo "noise_type: $noise_type"
    echo "noise_amount: $noise_amount"

    data_sub=$data/$noise_type.$noise_amount
    distill_sub=$distilled/$noise_type.$noise_amount

    model_path=$models/baseline

    if [[ -d $distill_sub ]]; then
        echo "Folder exists: $distill_sub"
        if [[ -f $distill_sub/train.bpe.$trg ]]; then
          echo "Distilled train data exists: $distill_sub/train.bpe.$trg"

          num_lines_train_src=`cat $distill_sub/train.bpe.$src | wc -l`
          num_lines_train_trg=`cat $distill_sub/train.bpe.$trg | wc -l`

          if [[ $num_lines_train_src == $num_lines_train_trg ]]; then
            echo "Same number of lines in training source and target:"
            echo "$num_lines_train_src == $num_lines_train_trg"
            echo "Skipping."
            continue
          fi
        fi
    fi

    if [ $(contains "${noise_types_subset[@]}" $noise_type) == "n" ]; then
        echo "noise_type not in subset that should be distilled"
        echo "Skipping."
        continue
    fi

    if [ $(contains "${noise_amounts_subset[@]}" $noise_amount) == "n" ]; then
        echo "noise_amount not in subset that should be distilled"
        echo "Skipping."
        continue
    fi

    mkdir -p $distill_sub

    # extract noise-only source training data

    num_noise_lines=`cat $data/raw/train/$noise_type.$noise_amount.tok.$src | wc -l`

    tail -n $num_noise_lines $data_sub/train.bpe.$src > $distill_sub/train.bpe.$src

    # link dev and test without modifying them

    for corpus in dev test; do
      ln -sfn $data_sub/$corpus.bpe.$src $distill_sub/$corpus.bpe.$src
      ln -sfn $data_sub/$corpus.bpe.$trg $distill_sub/$corpus.bpe.$trg
    done

    # translate training data with baseline model

    . $scripts/translation/decode_parallel_generic.sh &

  done
done
