#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

scripts=$base/scripts
analysis=$base/analysis

overlap=$analysis/overlap

mkdir -p $overlap

# filtered vs mined.mine

file_a=$analysis/filtered
file_b=$analysis/mined_raw/mined.mine.100

python scripts/analysis/sentence_pair_overlap.py --inputs $file_a $file_b

for output_method in common only-a only-b; do
  python scripts/analysis/sentence_pair_overlap.py --inputs $file_a $file_b --output $output_method > $overlap/$file_a.$file_b.$output_method
done

# dcce vs mined
