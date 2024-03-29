#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hpc

src=de
trg=en

data=$base/data

fast_align=$base/fast_align
alignments=$base/alignments

mkdir -p $alignments

for model_name in raw_paracrawl.100.filtered; do

    echo "model_name: $model_name"

    data_sub=$data/$model_name

    for lang in $src $trg; do
        cat $data_sub/train.bpe.$lang | python $base/scripts/analysis/strided_sample.py > $data_sub/train.bpe.sample.$lang
    done

# subword-level models

#    for fast_align_model in baseline raw_paracrawl.100 raw_paracrawl.100.filtered; do
#
#         echo "fast_align_model: $fast_align_model"
#
#         for reverse_method in min max mean geomean ignore only; do
#
#             echo "reverse_method: $reverse_method"
#
#             fast_align_sub=$fast_align/$fast_align_model
#             fast_align_sub_reverse="$fast_align/$fast_align_model"_reverse
#             alignments_sub=$alignments/$model_name.$fast_align_model.$reverse_method
#
#             if [[ -d $alignments_sub ]]; then
#              echo "alignments_sub exists: $alignments_sub"
#              echo "Skipping."
#              continue
#             fi
#
#             mkdir -p $alignments_sub
#
#             word_level_arg=""
#             smooth_method_arg=""
#
#             sbatch --cpus-per-task=1 --time=12:00:00 --mem=64G --partition=hpc $base/scripts/fast_align/weights_from_params_generic.sh \
#                 $base $fast_align_sub $alignments_sub $data_sub $fast_align_sub_reverse $reverse_method $word_level_arg $smooth_method_arg
#
#          done
#    done

    # word-level models

#    for fast_align_model in raw_paracrawl.100.filtered.word_level; do # baseline.word_level raw_paracrawl.100.word_level
#
#         echo "fast_align_model: $fast_align_model"
#
#         for reverse_method in min max mean geomean ignore only; do
#
#             echo "reverse_method: $reverse_method"
#
#             fast_align_sub=$fast_align/$fast_align_model
#             fast_align_sub_reverse="$fast_align/$fast_align_model"_reverse
#             alignments_sub=$alignments/$model_name.$fast_align_model.$reverse_method
#
#             if [[ -d $alignments_sub ]]; then
#              echo "alignments_sub exists: $alignments_sub"
#              echo "Skipping."
#              continue
#             fi
#
#             mkdir -p $alignments_sub
#
#             word_level_arg="--word-level"
#             smooth_method_arg=""
#
#             sbatch --cpus-per-task=1 --time=18:00:00 --mem=128G --partition=hpc $base/scripts/fast_align/weights_from_params_generic.sh \
#                 $base $fast_align_sub $alignments_sub $data_sub $fast_align_sub_reverse $reverse_method $word_level_arg $smooth_method_arg
#
#          done
#    done

    # word-level with window averaging

    for fast_align_model in raw_paracrawl.100.filtered.word_level; do # baseline.word_level raw_paracrawl.100.word_level

         echo "fast_align_model: $fast_align_model"

         for reverse_method in geomean; do # min max mean geomean ignore only

             echo "reverse_method: $reverse_method"

             for smooth_method in geomean; do # mean geomean

                 echo "smooth_method: $smooth_method"

                 fast_align_sub=$fast_align/$fast_align_model
                 fast_align_sub_reverse="$fast_align/$fast_align_model"_reverse
                 alignments_sub=$alignments/$model_name.$fast_align_model.$reverse_method.$smooth_method

                 if [[ -d $alignments_sub ]]; then
                  echo "alignments_sub exists: $alignments_sub"
                  echo "Skipping."
                  continue
                 fi

                 mkdir -p $alignments_sub

                 word_level_arg="--word-level"
                 smooth_method_arg="--smooth-method $smooth_method"

                 sbatch --cpus-per-task=1 --time=18:00:00 --mem=128G --partition=hpc $base/scripts/fast_align/weights_from_params_generic.sh \
                     $base $fast_align_sub $alignments_sub $data_sub $fast_align_sub_reverse $reverse_method $word_level_arg "$smooth_method_arg" $src $trg

              done
          done
    done

done


for model_name in raw_paracrawl.100.mined.score.0.75 raw_paracrawl.100.dcce.adq.0.75; do

    echo "model_name: $model_name"

    data_sub=$data/$model_name

    for lang in $src $trg; do
        cat $data_sub/train.bpe.$lang | python $base/scripts/analysis/strided_sample.py > $data_sub/train.bpe.sample.$lang
    done

    # word-level with window averaging

    fast_align_model=$model_name.word_level

     echo "fast_align_model: $fast_align_model"

     reverse_method="geomean"

     echo "reverse_method: $reverse_method"

     smooth_method="geomean"

     echo "smooth_method: $smooth_method"

     fast_align_sub=$fast_align/$fast_align_model
     fast_align_sub_reverse="$fast_align/$fast_align_model"_reverse
     alignments_sub=$alignments/$model_name.$fast_align_model.$reverse_method.$smooth_method

     if [[ -d $alignments_sub ]]; then
      echo "alignments_sub exists: $alignments_sub"
      echo "Skipping."
      continue
     fi

     mkdir -p $alignments_sub

     word_level_arg="--word-level"
     smooth_method_arg="--smooth-method $smooth_method"

     sbatch --cpus-per-task=1 --time=18:00:00 --mem=128G --partition=hpc $base/scripts/fast_align/weights_from_params_generic.sh \
         $base $fast_align_sub $alignments_sub $data_sub $fast_align_sub_reverse $reverse_method $word_level_arg "$smooth_method_arg" $src $trg

done

# DCCE and LASER data, but FA model trained on everything

for model_name in raw_paracrawl.100.mined.score.0.75 raw_paracrawl.100.dcce.adq.0.75; do

    echo "model_name: $model_name"

    data_sub=$data/$model_name

    for lang in $src $trg; do
        cat $data_sub/train.bpe.$lang | python $base/scripts/analysis/strided_sample.py > $data_sub/train.bpe.sample.$lang
    done

    # word-level with window averaging

    fast_align_model="raw_paracrawl.100.filtered.word_level"

     echo "fast_align_model: $fast_align_model"

     reverse_method="geomean"

     echo "reverse_method: $reverse_method"

     smooth_method="geomean"

     echo "smooth_method: $smooth_method"

     fast_align_sub=$fast_align/$fast_align_model
     fast_align_sub_reverse="$fast_align/$fast_align_model"_reverse
     alignments_sub=$alignments/$model_name.$fast_align_model.$reverse_method.$smooth_method

     if [[ -d $alignments_sub ]]; then
      echo "alignments_sub exists: $alignments_sub"
      echo "Skipping."
      continue
     fi

     mkdir -p $alignments_sub

     word_level_arg="--word-level"
     smooth_method_arg="--smooth-method $smooth_method"

     sbatch --cpus-per-task=1 --time=18:00:00 --mem=128G --partition=hpc $base/scripts/fast_align/weights_from_params_generic.sh \
         $base $fast_align_sub $alignments_sub $data_sub $fast_align_sub_reverse $reverse_method $word_level_arg "$smooth_method_arg" $src $trg

done
