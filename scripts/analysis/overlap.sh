#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

scripts=$base/scripts
analysis=$base/analysis

overlap=$analysis/overlap

mkdir -p $overlap

# filtered vs mined.mine

file_a=$analysis/filtered
file_b=$analysis/mined_raw/mined.mine.100

log_file=$overlap/filtered+mined.mine.100.no-out.log

python $scripts/analysis/sentence_pair_overlap.py --inputs $file_a $file_b 2>&1 | tee -a $log_file

for output_method in common only-a only-b; do
  log_file=$overlap/filtered+mined.mine.100.$output_method.log
  python $scripts/analysis/sentence_pair_overlap.py --inputs $file_a $file_b --output $output_method > $overlap/filtered+mined.mine.100.$output_method 2>&1 | tee -a $log_file
done

# dcce vs mined

for dcce_method in adq adq-dom; do
    for mining_method in mine score; do
        for fraction in 0.25 0.5 0.75; do
            name_a=dcce.$dcce_method.$fraction
            name_b=mined.$mining_method.$fraction

            file_a=$analysis/$name_a
            file_b=$analysis/mined_bpe/$name_b

            log_file=$overlap/$name_a+$name_b.no-out.log

            python $scripts/analysis/sentence_pair_overlap.py --inputs $file_a $file_b 2>&1 | tee -a $log_file

            for output_method in common only-a only-b; do
              log_file=$overlap/$name_a+$name_b.$output_method.log
              python $scripts/analysis/sentence_pair_overlap.py --inputs $file_a $file_b --output $output_method > $overlap/$name_a+$name_b.$output_method 2>&1 | tee -a $log_file
            done
        done
    done
done
