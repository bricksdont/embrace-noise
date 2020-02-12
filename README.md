# noise-distill

## Setup

Create new Python 3 virtual env:

    ./scripts/make_virtualenv.sh

Activate the env, then install software:

    ./scripts/download_install_packages.sh

Download and rearrange data:

    ./scripts/download_data.sh

## Prepare data

Individual steps involved, they are not necessarily listed in the correct order as some
scripts need to be run several times. For instance, baseline models need to be trained before scoring,
and after scoring, prepare needs to run again.

Filter tokenized training sets:

    ./scripts/preprocessing/filter_all.sh

Apply BPE to all data sets:

    ./scripts/preprocessing/preprocess_all.sh

Distill some data sets:

    ./scripts/translation/distill_all.sh
    
Score data sets with DCCE (this only works _after training the baseline and reverse baseline):

    ./scripts/scoring/score_all.sh
    ./scripts/scoring/dual_conditional_cross_entropy_scoring.sh

Mine bitext with LASER:

    ./scripts/mining/mine_all.sh

Assemble all kinds of training data (noise types,
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
