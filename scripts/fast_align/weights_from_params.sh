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

    for fast_align_model in baseline raw_paracrawl.100 raw_paracrawl.100.filtered; do

         echo "fast_align_model: $fast_align_model"

         for reverse_method in min max mean ignore only; do

             echo "reverse_method: $reverse_method"

             data_sub=$data/$model_name
             fast_align_sub=$fast_align/$fast_align_model
             fast_align_sub_reverse="$fast_align/$fast_align_model"_reverse
             alignments_sub=$alignments/$model_name.$fast_align_model.$reverse_method

             if [[ -d $alignments_sub ]]; then
              echo "alignments_sub exists: $alignments_sub"
              echo "Skipping."
              continue
             fi

             mkdir -p $alignments_sub

             word_level_arg=""

             sbatch --cpus-per-task=1 --time=12:00:00 --mem=64G --partition=hpc $base/scripts/fast_align/weights_from_params_generic.sh \
                 $base $fast_align_sub $alignments_sub $data_sub $fast_align_sub_reverse $reverse_method $word_level_arg

          done
    done

    # word-level models

    for fast_align_model in baseline.word_level raw_paracrawl.100.word_level raw_paracrawl.100.filtered.word_level; do

         echo "fast_align_model: $fast_align_model"

         for reverse_method in min max mean ignore only; do

             echo "reverse_method: $reverse_method"

             data_sub=$data/$model_name
             fast_align_sub=$fast_align/$fast_align_model
             fast_align_sub_reverse="$fast_align/$fast_align_model"_reverse
             alignments_sub=$alignments/$model_name.$fast_align_model.$reverse_method

             if [[ -d $alignments_sub ]]; then
              echo "alignments_sub exists: $alignments_sub"
              echo "Skipping."
              continue
             fi

             mkdir -p $alignments_sub

             word_level_arg="--word-level"

             sbatch --cpus-per-task=1 --time=12:00:00 --mem=64G --partition=hpc $base/scripts/fast_align/weights_from_params_generic.sh \
                 $base $fast_align_sub $alignments_sub $data_sub $fast_align_sub_reverse $reverse_method $word_level_arg

          done
    done

done
