#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/fairseq3/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hydra

trg=en

data=$base/data
scripts=$base/scripts
preprocessed=$base/preprocessed

preprocessed_lm=$base/preprocessed_lm

mkdir -p $preprocessed_lm

num_lines=1000000
num_workers=8

for name in baseline raw_paracrawl.100; do

  echo "LM model: $name"

  preprocessed_sub=$preprocessed/$name
  preprocessed_lm_sub=$preprocessed_lm/$name

  if [[ -d $preprocessed_lm_sub ]]; then
      echo "Folder exists: $preprocessed_lm_sub"
      echo "Skipping."
      continue
  fi

  mkdir -p $preprocessed_lm_sub

  # take first $num_lines lines from target BPE training data

  head -n $num_lines $preprocessed_sub/train.bpe.$trg > $preprocessed_lm_sub/train.bpe.$trg

  # link dev and test BPE files

  for corpus in dev test; do
    ln -snf $data/baseline/$corpus.bpe.$trg $preprocessed_lm_sub/$corpus.bpe.$trg
  done

  sbatch --cpus-per-task=$num_workers --time=01:00:00 --mem=4G --partition=hydra $scripts/preprocessing/preprocess_lm_generic.sh $preprocessed_lm_sub $preprocessed_lm_sub $trg $num_workers

done
