#! /bin/bash

sbatch --cpus-per-task=1 --time=00:15:00 --mem=16G --partition=hydra /net/cephfs/home/mathmu/scratch/noise-distill/scripts/analysis/overlap.sh
