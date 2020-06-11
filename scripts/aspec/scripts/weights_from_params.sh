#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill/aspec
basebase=/net/cephfs/home/mathmu/scratch/noise-distill

source $basebase/venvs/sockeye3-cpu/bin/activate
module unuse /apps/etc/modules/start/
module use /sapps/etc/modules/start/
module load hpc

src=en
trg=ja

data=$base/data

fast_align=$base/fast_align
alignments=$base/alignments

mkdir -p $alignments

for model_name in noise2.filtered; do

    echo "model_name: $model_name"

    data_sub=$data/$model_name

    for lang in $src $trg; do
        cat $data_sub/train.bpe.$lang | python $basebase/scripts/analysis/strided_sample.py > $data_sub/train.bpe.sample.$lang
    done

    # word-level with window averaging

    for fast_align_model in noise2.filtered.word_level; do

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

         sbatch --cpus-per-task=1 --time=18:00:00 --mem=128G --partition=hpc \
             $basebase/scripts/fast_align/weights_from_params_generic.sh \
                 $basebase $fast_align_sub $alignments_sub $data_sub $fast_align_sub_reverse \
                 $reverse_method $word_level_arg "$smooth_method_arg" $src $trg

    done
done
