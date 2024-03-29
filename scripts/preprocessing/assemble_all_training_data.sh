#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate

src=de
trg=en

scripts=$base/scripts

data=$base/data
preprocessed=$base/preprocessed
filtered=$base/filtered
distilled=$base/distilled
scores=$base/scores
mined=$base/mined
dcce=$base/dcce

shared_models=$base/shared_models

MOSES=$base/tools/moses-scripts/scripts

bpe_vocab_threshold=50

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

if [[ ! -d  $data_sub ]]; then
    mkdir -p $data_sub

    for corpus in train dev test; do
      ln -snf $preprocessed/baseline/$corpus.bpe.$src $data_sub/$corpus.bpe.$src
      ln -snf $preprocessed/baseline/$corpus.bpe.$trg $data_sub/$corpus.bpe.$trg
    done
else
    echo "data_sub exists: $data_sub"
    echo "Skipping."
fi

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

if [[ ! -d  $data_sub ]]; then
    mkdir -p $data_sub

    ln -snf $filtered/baseline/train.bpe.$src $data_sub/train.bpe.$src
    ln -snf $filtered/baseline/train.bpe.$trg $data_sub/train.bpe.$trg

    for corpus in dev test; do
      ln -snf $preprocessed/baseline/$corpus.bpe.$src $data_sub/$corpus.bpe.$src
      ln -snf $preprocessed/baseline/$corpus.bpe.$trg $data_sub/$corpus.bpe.$trg
    done
else
    echo "data_sub exists: $data_sub"
    echo "Skipping."
fi


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

if [[ ! -d  $data_sub ]]; then
    mkdir -p $data_sub

    for corpus in train dev test; do
      ln -snf $data/baseline/$corpus.bpe.$src $data_sub/$corpus.bpe.$trg
      ln -snf $data/baseline/$corpus.bpe.$trg $data_sub/$corpus.bpe.$src
    done
else
    echo "data_sub exists: $data_sub"
    echo "Skipping."
fi

# assemble training data for: DCCE score filtering

shopt -s nullglob

for dcce_sub in $dcce/*; do

  for fraction in 0.25 0.5 0.75; do

      for dcce_method in adq adq-dom; do

          model_name=$(basename $dcce_sub)

          model_name=$model_name.dcce.$dcce_method.$fraction
          data_sub=$data/$model_name

          if [[ -d $data_sub ]]; then
            echo "data_sub exists: $data_sub"
            echo "Skipping."
            continue
          fi

          num_lines=`cat $dcce_sub/scores.$dcce_method.all.sorted | wc -l`

          origin_sub=$(mktemp -d)

          cat $dcce_sub/scores.$dcce_method.all.sorted | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines | cut -f2 > $origin_sub/train.bpe.$src
          cat $dcce_sub/scores.$dcce_method.all.sorted | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines | cut -f3 > $origin_sub/train.bpe.$trg

          . $scripts/preprocessing/concat_with_baseline_generic.sh

      done
  done
done

# assemble training data for: laser mining

for mined_sub in $mined/*; do

  for fraction in 0.25 0.5 0.75; do

      for mining_method in mine score; do

          model_name=$(basename $mined_sub)
          original_name=$model_name

          model_name=$model_name.mined.$mining_method.$fraction
          data_sub=$data/$model_name

          if [[ -d $data_sub ]]; then
            echo "data_sub exists: $data_sub"
            echo "Skipping."
            continue
          fi

          num_lines=`cat $filtered/$original_name/train.bpe.$src | wc -l`

          origin_sub=$(mktemp -d)

          cat $mined_sub/mined.$mining_method.sorted | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines | cut -f2 > $origin_sub/train.$src
          cat $mined_sub/mined.$mining_method.sorted | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines | cut -f3 > $origin_sub/train.$trg

          for lang in $src $trg; do
            cat $origin_sub/train.$lang | perl $MOSES/tokenizer/normalize-punctuation.perl $lang > $origin_sub/train.normalized.$lang
            cat $origin_sub/train.normalized.$lang | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $lang > $origin_sub/train.tok.$lang

            subword-nmt apply-bpe -c $shared_models/baseline/$src$trg.bpe \
            --vocabulary $shared_models/baseline/vocab.$lang \
            --vocabulary-threshold $bpe_vocab_threshold < $origin_sub/train.tok.$lang > $origin_sub/train.bpe.$lang
          done

        . $scripts/preprocessing/concat_with_baseline_generic.sh

      done
  done
done


# tagged versions of noise_type.noise_amount

for preprocessed_sub in $preprocessed/*; do

    model_name=$(basename $preprocessed_sub)

    if [[ $model_name == "baseline" ]]; then
      # tagging baseline does not make sense
      echo "Skipping baseline.tagged"
      continue
    fi

    substring=".tagged"

    if [[ $model_name =~ $substring ]]; then
      # do not retag tagged data
      echo "Data tagged already: $model_name"
      echo "Skipping."
      continue
    fi

    model_name=$model_name.tagged

    origin_sub=$preprocessed/$model_name
    data_sub=$data/$model_name

    mkdir -p $origin_sub

    if [[ -d $data_sub ]]; then
      echo "data_sub exists: $data_sub"
      echo "Skipping."
      continue
    fi

    # add tag to training data

    for lang in $src $trg; do
      cat $preprocessed_sub/train.bpe.$lang | python $scripts/preprocessing/add_tag_to_lines.py --tag "<N>" > $origin_sub/train.bpe.$lang
    done

    . $scripts/preprocessing/concat_with_baseline_generic.sh

done

# tagged version of filtered data sets

for filtered_sub in $filtered/*; do

    model_name=$(basename $filtered_sub)

    if [[ $model_name == "baseline" ]]; then
      # tagging filtered baseline does not make sense
      echo "Skipping baseline.filtered.tagged"
      continue
    fi

    substring=".tagged"

    if [[ $model_name =~ $substring ]]; then
      # do not retag tagged data
      echo "Data tagged already: $model_name"
      echo "Skipping."
      continue
    fi

    model_name=$model_name.filtered.tagged

    origin_sub=$preprocessed/$model_name
    data_sub=$data/$model_name

    mkdir -p $origin_sub

    if [[ -d $data_sub ]]; then
      echo "data_sub exists: $data_sub"
      echo "Skipping."
      continue
    fi

    # add tag to training data

    for lang in $src $trg; do
      cat $filtered_sub/train.bpe.$lang | python $scripts/preprocessing/add_tag_to_lines.py --tag "<N>" > $origin_sub/train.bpe.$lang
    done

    . $scripts/preprocessing/concat_with_baseline_generic.sh

done

# tagged fraction versions of filtered data sets

for filtered_sub in $filtered/*; do

    for fraction in 0.25 0.5 0.75; do

        model_name=$(basename $filtered_sub)

        if [[ $model_name == "baseline" ]]; then
          # tagging filtered baseline does not make sense
          echo "Skipping baseline.filtered.tagged"
          continue
        fi

        substring=".tagged"

        if [[ $model_name =~ $substring ]]; then
          # do not retag tagged data
          echo "Data tagged already: $model_name"
          echo "Skipping."
          continue
        fi

        model_name=$model_name.filtered.tagged.$fraction

        origin_sub=$preprocessed/$model_name
        data_sub=$data/$model_name

        mkdir -p $origin_sub

        if [[ -d $data_sub ]]; then
          echo "data_sub exists: $data_sub"
          echo "Skipping."
          continue
        fi

        # subsample training data

        num_lines=`cat $filtered_sub/train.bpe.$src | wc -l`

        cat $filtered_sub/train.bpe.$src | python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines > $origin_sub/train.bpe_no_tag.$src
        cat $filtered_sub/train.bpe.$trg| python $scripts/preprocessing/head_fraction.py --fraction $fraction --size $num_lines > $origin_sub/train.bpe_no_tag.$trg

        # add tag to training data

        for lang in $src $trg; do
          cat $origin_sub/train.bpe_no_tag.$lang | python $scripts/preprocessing/add_tag_to_lines.py --tag "<N>" > $origin_sub/train.bpe.$lang
        done

        . $scripts/preprocessing/concat_with_baseline_generic.sh

    done
done



echo "Sizes of all files:"

wc -l $data/*/*
