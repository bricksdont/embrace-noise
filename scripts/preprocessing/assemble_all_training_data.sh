#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

src=de
trg=en

scripts=$base/scripts

data=$base/data
preprocessed=$base/preprocessed
filtered=$base/filtered
distilled=$base/distilled
scores=$base/scores
mined=$base/mined

# preconditions: first run the following:

# apply rule-based filtering versions of initial data sets
# (results in filtered)

# . $scripts/preprocessing/filter_all.sh

# learn BPE model on baseline data and apply BPE to all initial data sets
# (results in preprocessed)

# . $scripts/preprocessing/preprocess_all.sh

# distill some initial data sets
# (results in distilled)

# . $scripts/preprocessing/distill_all.sh

# vanilla baseline custom assemble

data_sub=$data/baseline
mkdir -p $data_sub

for corpus in train dev test; do
  ln -snf $preprocessed/baseline/$corpus.bpe.$src $data_sub/$corpus.bpe.$src
  ln -snf $preprocessed/baseline/$corpus.bpe.$trg $data_sub/$corpus.bpe.$trg
done

# assemble training data for: $noise_type.$noise_amount
# (without vanilla baseline, should be skipped)

for origin_sub in $preprocessed/*; do

  model_name=$(basename $origin_sub)
  data_sub=$data/$model_name

  if [[ -d $data_sub ]]; then
    echo "data_sub exists: $data_sub"
    echo "Skipping."
    continue
  fi

  . $scripts/preprocessing/concat_with_baseline_generic.sh
done

# custom assemble for baseline.filtered (do not concat with unfiltered baseline)

data_sub=$data/baseline.filtered
mkdir -p $data_sub

ln -snf $filtered/baseline/train.bpe.$src $data_sub/train.bpe.$src
ln -snf $filtered/baseline/train.bpe.$trg $data_sub/train.bpe.$trg

for corpus in dev test; do
  ln -snf $preprocessed/baseline/$corpus.bpe.$src $data_sub/$corpus.bpe.$src
  ln -snf $preprocessed/baseline/$corpus.bpe.$trg $data_sub/$corpus.bpe.$trg
done

# assemble training data for: $noise_type.$noise_amount.filtered
# (without filtered baseline, should be skipped)

for origin_sub in $filtered/*; do
  model_name=$(basename $origin_sub)
  model_name=$model_name."filtered"

  data_sub=$data/$model_name

  if [[ -d $data_sub ]]; then
    echo "data_sub exists: $data_sub"
    echo "Skipping."
    continue
  fi

  . $scripts/preprocessing/concat_with_baseline_generic.sh
done

# assemble training data for: $noise_type.$noise_amount.distilled
# (this includes distilled baseline)

for origin_sub in $distilled/*; do
  model_name=$(basename $origin_sub)
  model_name=$model_name."distilled"

  data_sub=$data/$model_name

  if [[ -d $data_sub ]]; then
    echo "data_sub exists: $data_sub"
    echo "Skipping."
    continue
  fi

  . $scripts/preprocessing/concat_with_baseline_generic.sh
done

# assemble training data for: reverse baseline model (custom)

data_sub=$data/baseline.reverse
mkdir -p $data_sub

for corpus in train dev test; do
  ln -snf $data/baseline/$corpus.bpe.$src $data_sub/$corpus.bpe.$trg
  ln -snf $data/baseline/$corpus.bpe.$trg $data_sub/$corpus.bpe.$src
done

# assemble training data for: DCCE score filtering

shopt -s nullglob

for origin_sub in $scores/*; do
  model_name=$(basename $origin_sub)

  for fraction in 0.25 0.5 0.75; do

    model_name=$model_name.dcce.$fraction
    data_sub=$data/model_name

    cat $origin_sub/scores.all.sorted | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines | cut -f2 > $origin_sub/train.bpe.$src
    cat $origin_sub/scores.all.sorted | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines | cut -f3 > $origin_sub/train.bpe.$trg

    if [[ -d $data_sub ]]; then
    echo "data_sub exists: $data_sub"
    echo "Skipping."
    continue
    fi

    . $scripts/preprocessing/concat_with_baseline_generic.sh
  done
done

# assemble training data for: laser mining

for origin_sub in $mined/*; do
  model_name=$(basename $origin_sub)

  for fraction in 0.25 0.5 0.75; do

    model_name=$model_name.mined.$fraction
    data_sub=$data/model_name

    cat $origin_sub/mined | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines | cut -f2 > $origin_sub/train.bpe.$src
    cat $origin_sub/mined | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines | cut -f3 > $origin_sub/train.bpe.$trg

    if [[ -d $data_sub ]]; then
    echo "data_sub exists: $data_sub"
    echo "Skipping."
    continue
    fi

    . $scripts/preprocessing/concat_with_baseline_generic.sh
  done
done

echo "Sizes of all files:"

wc -l $data/*/*
