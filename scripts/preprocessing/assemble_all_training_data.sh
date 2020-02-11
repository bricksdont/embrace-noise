#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

src=de
trg=en

scripts=$base/scripts

data=$base/data
preprocessed=$base/preprocessed
filtered=$base/filtered
distilled=$base/distilled

# learn BPE model on baseline data and apply BPE to all initial data sets
# (results in preprocessed)

. $scripts/preprocessing/preprocess_all.sh

# apply rule-based filtering versions of initial data sets
# (results in filtered)

. $scripts/preprocessing/filter_all.sh

# distill some initial data sets
# (results in distilled)

. $scripts/preprocessing/distill_all.sh


# assemble training data for: $noise_type.$noise_amount
# (this includes vanilla baseline)

for data_sub in $preprocessed/*; do
  . $scripts/preprocessing/concat_with_baseline_generic.sh
done

# assemble training data for: $noise_type.$noise_amount filtered
# (this includes filtered baseline)

for data_sub in $filtered/*; do
  . $scripts/preprocessing/concat_with_baseline_generic.sh
done

# assemble training data for: $noise_type.$noise_amount distilled
# (this includes distilled baseline)

for data_sub in $distilled/*; do
  . $scripts/preprocessing/concat_with_baseline_generic.sh
done
