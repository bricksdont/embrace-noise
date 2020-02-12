#! /bin/bash

# this code is adapted from:
# https://github.com/facebookresearch/LASER/blob/master/tasks/bucc/bucc.sh

base=/net/cephfs/home/mathmu/scratch/noise-distill

source $base/venvs/laser3/bin/activate

tools=$base/tools
data=$base/data
scripts=$base/scripts

LASER=$tools/laser

embedded=$base/embedded
prefiltered=$base/prefiltered
mined=$base/mined

mkdir -p $mined

device_arg="--gpu"

# CS Bulletin pdf corpus

languages=("de" "en" "fr" "it")

raw_prefix="cs-bulletin"
embedded_prefix="cs-bulletin.embeddings"
mined_prefix="cs-bulletin.mined"

# conservative threshold (could be lower for this corpus)

mining_threshold=1.1

for src in ${languages[@]} ; do
    for trg in ${languages[@]} ; do
        if [[ ${src} != ${trg} ]] ; then
            mined_file=$mined/$mined_prefix.${src}-${trg}

            raw_src=$data/$raw_prefix.$src
            raw_trg=$data/$raw_prefix.$trg

            embeddings_src=$embedded/$embedded_prefix.$src
            embeddings_trg=$embedded/$embedded_prefix.$trg

            if [ ! -s ${mined_file} ] ; then
                echo "Extracting bitexts for $mined_prefix.${src}-${trg}"
                sbatch --qos=vesta --time=12:00:00 --gres gpu:Tesla-V100:1 --cpus-per-task 3 --mem 48g $scripts/laser/mine_generic.sh $LASER $raw_src \
                  $raw_trg $src $trg $embeddings_src $embeddings_trg $mined_file $mining_threshold $device_arg

            else
                echo "File exists: $mined_file"
                echo "Skipping."
            fi
        fi
    done
done
