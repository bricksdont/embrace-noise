#! /bin/bash

# S3IT
source /net/cephfs/home/mathmu/scratch/goeckeritz-model/venvs/sockeye3-cpu/bin/activate

# work around slurm placing scripts in var folder
base=/net/cephfs/home/mathmu/scratch/goeckeritz-model

data=$base/data

python -m sockeye.prepare_data \
                        -s $data/train.en \
                        -t $data/train.de \
			--shared-vocab \
                        -o $data/prepared
