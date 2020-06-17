#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $basebase/venvs/sockeye3-cpu/bin/activate

src=en
trg=ja

scripts=$basebase/scripts

data=$base/data
filtered=$base/filtered
mined=$base/mined
dcce=$base/dcce
tools=$base/tools
alignments=$base/alignments
shared_models=$base/shared_models

MOSES=$basebase/tools/moses-scripts/scripts

export LD_LIBRARY_PATH=$tools/usr/local/lib

bpe_vocab_threshold=10

shopt -s nullglob

# assemble baseline + filtered noisy parts

for origin_sub in $filtered/noise1-only $filtered/noise2-only; do
  model_name=$(basename $origin_sub)
  model_name=$model_name."filtered"

  data_sub=$data/$model_name

  if [[ -d $data_sub ]]; then
    echo "data_sub exists: $data_sub"
    echo "Skipping."
    continue
  fi

  for lang in $src $trg; do
      if [[ ! -f $origin_sub/train.bpe.$lang ]]; then
          if [[ -f $origin_sub/train.tok.$lang ]]; then

              subword-nmt apply-bpe -c $shared_models/baseline/$src$trg.bpe \
                 --vocabulary $shared_models/baseline/vocab.$lang \
                 --vocabulary-threshold $bpe_vocab_threshold < $origin_sub/train.tok.$lang > $origin_sub/train.bpe.$lang
          else
              echo "Both files do not exist:"
              echo "$origin_sub/train.bpe.$lang"
              echo "$origin_sub/train.tok.$lang"
          fi
      fi
  done

  . $scripts/preprocessing/concat_with_baseline_generic.sh
done

# assemble LASER scoring data

for mined_sub in $mined/*; do

  for fraction in 0.25 0.5 0.75; do

      mining_method="score"

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

         if [[ $lang == "ja" ]]; then
            # juman tokenization
            # see http://lotus.kuee.kyoto-u.ac.jp/WAT/WAT2019/baseline/dataPreparationJE.html

            cat $origin_sub/train.$lang | \
              perl -CSD -Mutf8 -pe 's/　/ /g;' | \
              $tools/usr/local/bin/juman -r $tools/usr/local/etc/jumanrc -b | \
              perl -ne 'chomp; if($_ eq "EOS"){print join(" ",@b),"\n"; @b=();} else {@a=split/ /; push @b, $a[0];}' | \
              perl -pe 's/^ +//; s/ +$//; s/ +/ /g;' | \
              perl -CSD -Mutf8 -pe 'tr/\|[]/｜［］/; ' \
              > $origin_sub/train.tok.$lang

        else
            # assume lang is en, Moses tokenization

            cat $origin_sub/train.$lang | \
              perl $MOSES/tokenizer/tokenizer.perl -a -q -no-escape -l $lang > $origin_sub/train.tok.$lang
        fi

        subword-nmt apply-bpe -c $shared_models/baseline/$src$trg.bpe \
        --vocabulary $shared_models/baseline/vocab.$lang \
        --vocabulary-threshold $bpe_vocab_threshold < $origin_sub/train.tok.$lang > $origin_sub/train.bpe.$lang
      done

    . $scripts/preprocessing/concat_with_baseline_generic.sh
  done
done

# assemble DCCE data

for dcce_sub in $dcce/*; do
  for fraction in 0.25 0.5 0.75; do

      dcce_method="adq"

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

# assemble LASER instance weighting data

for mined_sub in $mined/*; do

    mining_method=score

    model_name=$(basename $mined_sub)

    model_name=$model_name.mined.$mining_method.instance_weighting
    data_sub=$data/$model_name

    if [[ -d $data_sub ]]; then
      echo "data_sub exists: $data_sub"
      echo "Skipping."
      continue
    fi

    num_lines_baseline=`cat $data/baseline/train.bpe.$src | wc -l`

    origin_sub=$(mktemp -d)

    cat $mined_sub/mined.$mining_method.sorted | cut -f2 > $origin_sub/train.$src
    cat $mined_sub/mined.$mining_method.sorted | cut -f3 > $origin_sub/train.$trg

    python $scripts/preprocessing/create_weights.py --method ones --size $num_lines_baseline > $origin_sub/scores.1

    cut -f1 $mined_sub/mined.$mining_method.sorted | python $scripts/preprocessing/min_max_scaling.py > $origin_sub/scores.2

    mkdir -p $data_sub

    cat $origin_sub/scores.1 $origin_sub/scores.2 > $data_sub/train.weights

    for lang in $src $trg; do

         if [[ $lang == "ja" ]]; then
            # juman tokenization
            # see http://lotus.kuee.kyoto-u.ac.jp/WAT/WAT2019/baseline/dataPreparationJE.html

            cat $origin_sub/train.$lang | \
              perl -CSD -Mutf8 -pe 's/　/ /g;' | \
              $tools/usr/local/bin/juman -r $tools/usr/local/etc/jumanrc -b | \
              perl -ne 'chomp; if($_ eq "EOS"){print join(" ",@b),"\n"; @b=();} else {@a=split/ /; push @b, $a[0];}' | \
              perl -pe 's/^ +//; s/ +$//; s/ +/ /g;' | \
              perl -CSD -Mutf8 -pe 'tr/\|[]/｜［］/; ' \
              > $origin_sub/train.tok.$lang

        else
            # assume lang is en, Moses tokenization

            cat $origin_sub/train.$lang | \
              perl $MOSES/tokenizer/tokenizer.perl -a -q -no-escape -l $lang > $origin_sub/train.tok.$lang
        fi

        subword-nmt apply-bpe -c $shared_models/baseline/$src$trg.bpe \
        --vocabulary $shared_models/baseline/vocab.$lang \
        --vocabulary-threshold $bpe_vocab_threshold < $origin_sub/train.tok.$lang > $origin_sub/train.bpe.$lang
      done

    . $scripts/preprocessing/concat_with_baseline_generic.sh

done

# assemble LASER instance weighting data with exp smoothing

for mined_sub in $mined/*; do

    mining_method=score

    model_name=$(basename $mined_sub)

    model_name=$model_name.mined.$mining_method.instance_weighting
    original_data_sub=$data/$model_name

    for exp in 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0; do

        data_sub=$original_data_sub.exp$exp

        if [[ -d $data_sub ]]; then
          echo "data_sub exists: $data_sub"
          echo "Skipping."
          continue
        fi

        mkdir -p $data_sub

        for lang in $src $trg; do
            for corpus in train dev test; do
                ln -snf $original_data_sub/$corpus.bpe.$lang $data_sub/$corpus.bpe.$lang
            done
        done

        cat $original_data_sub/train.weights | python $scripts/preprocessing/exponential_smoothing.py --exp $exp > \
            $data_sub/train.weights

    done
done

# assemble DCCE instance weighting data

for dcce_sub in $dcce/*; do

  dcce_method="adq"

  model_name=$(basename $dcce_sub)

  model_name=$model_name.dcce.$dcce_method.instance_weighting
  data_sub=$data/$model_name

  if [[ -d $data_sub ]]; then
    echo "data_sub exists: $data_sub"
    echo "Skipping."
    continue
  fi

  num_lines_baseline=`cat $data/baseline/train.bpe.$src | wc -l`

  origin_sub=$(mktemp -d)

  cat $dcce_sub/scores.$dcce_method.all.sorted | cut -f2 > $origin_sub/train.bpe.$src
  cat $dcce_sub/scores.$dcce_method.all.sorted | cut -f3 > $origin_sub/train.bpe.$trg

  python $scripts/preprocessing/create_weights.py --method ones --size $num_lines_baseline > $origin_sub/scores.1

  cut -f1 $dcce_sub/scores.$dcce_method.all.sorted | python $scripts/preprocessing/min_max_scaling.py > $origin_sub/scores.2

  mkdir -p $data_sub

  cat $origin_sub/scores.1 $origin_sub/scores.2 > $data_sub/train.weights

  . $scripts/preprocessing/concat_with_baseline_generic.sh

done

# assemble DCCE instance weighting data with exp smoothing

for dcce_sub in $dcce/*; do

  dcce_method=adq

  model_name=$(basename $dcce_sub)

  model_name=$model_name.dcce.$dcce_method.instance_weighting
  original_data_sub=$data/$model_name

  for exp in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9; do

      data_sub=$original_data_sub.exp$exp

      if [[ -d $data_sub ]]; then
        echo "data_sub exists: $data_sub"
        echo "Skipping."
        continue
      fi

      mkdir -p $data_sub

      for lang in $src $trg; do
          for corpus in train dev test; do
              ln -snf $original_data_sub/$corpus.bpe.$lang $data_sub/$corpus.bpe.$lang
          done
      done

      cat $original_data_sub/train.weights | python $scripts/preprocessing/exponential_smoothing.py --exp $exp > \
          $data_sub/train.weights

  done
done

# assemble FA token weighting data: clean corpus has FA weights as well

for exp in 0.05 0.1 0.2 0.3 0.4 0.5; do

    reverse_method="geomean"
    original_name="noise2-only.filtered"
    fast_align_model="noise2-only.filtered"

    original_data_sub=$data/$original_name

    name=$original_name.token_weighting.exp$exp.$reverse_method
    data_sub=$data/$name

    if [[ -d $data_sub ]]; then
        echo "data_sub exists: $data_sub"
        echo "Skipping."
        continue
    fi

    mkdir -p $data_sub

    alignments_sub=$alignments/$original_name.$fast_align_model.word_level.$reverse_method.geomean

     # link entire data folder

    for lang in $src $trg; do
        for corpus in train dev test; do
            ln -snf $original_data_sub/$corpus.bpe.$lang $data_sub/$corpus.bpe.$lang
        done
    done

    # token weights

    cat $alignments_sub/weights | python $scripts/preprocessing/exponential_smoothing.py --exp $exp > \
      $data_sub/train.weights
done

# systems with fast_align token-level weights: clean corpus has 1.0 for all tokens

# TODO: wait until results from DE-EN
