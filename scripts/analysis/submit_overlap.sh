#! /bin/bash

sbatch --cpus-per-task=1 --time=01:30:00 --mem=100G --partition=hydra /net/cephfs/home/mathmu/scratch/noise-distill/scripts/analysis/overlap.sh
