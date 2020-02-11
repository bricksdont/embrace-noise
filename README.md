# noise-distill

## Setup

Create new Python 3 virtual env:

    ./scripts/make_virtualenv.sh

Activate the env, then install software:

    ./scripts/download_install_packages.sh

Download and rearrange data:

    ./scripts/download_data.sh

## Prepare data

Assemble all kinds of training data (applying BPE,
rule-based filtering, distillation, combined in different ways):

    ./scripts/preprocessing/assemble_all_training_data.sh

Then prepare training shards for Sockeye:

    ./scripts/preprocessing/prepare_data_all.sh

## Model training

    ./scripts/training/train_all.sh

## Translation

    ./scripts/translation/translate_all.sh

## Evaluation

    ./scripts/evaluation/evaluate_all.sh
