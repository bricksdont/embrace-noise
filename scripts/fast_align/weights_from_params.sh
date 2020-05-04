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

for model_name in raw_paracrawl.100.filtered; do

  for fast_align_model in baseline raw_paracrawl.100 raw_paracrawl.100.filtered; do

       data_sub=$data/$model_name
       fast_align_sub=$fast_align/$fast_align_model
       alignments_sub=$alignments/$model_name.$fast_align_model

       if [[ -d $alignments_sub ]]; then
        echo "alignments_sub exists: $alignments_sub"
        echo "Skipping."
        continue
       fi

       mkdir -p $alignments_sub

       sbatch --cpus-per-task=1 --time=05:00:00 --mem=32G --partition=hpc $base/scripts/fast_align/weights_from_params_generic.sh $base $fast_align_sub $alignments_sub $data_sub

  done
done
