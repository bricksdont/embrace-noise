#! /bin/bash

# calling script has to set:

# $base
# $shared_models_individual
# $noise_type
# $noise_amount
# $bpe_vocab_threshold
# $bpe_total_symbols
# $train_src
# $train_trg

scripts=$base/scripts

src=de
trg=en

#################

echo "noise_type: $noise_type"
echo "noise_amount: $noise_amount"

# learn BPE model on train (concatenate both languages)

subword-nmt learn-joint-bpe-and-vocab -i $train_src $train_trg \
  --write-vocabulary $shared_models_individual/vocab.$src $shared_models_individual/vocab.$trg \
  --total-symbols $bpe_total_symbols -o $shared_models_individual/$src$trg.bpe

# apply BPE model to train, test and dev

for corpus in train dev test; do
  subword-nmt apply-bpe -c $base/shared_models/$src$trg.$domain.bpe --vocabulary $base/shared_models/vocab.$domain.$src --vocabulary-threshold $bpe_vocab_threshold < $data/$corpus.truecased.$src > $data/$corpus.bpe.$src
  subword-nmt apply-bpe -c $base/shared_models/$src$trg.$domain.bpe --vocabulary $base/shared_models/vocab.$domain.$trg --vocabulary-threshold $bpe_vocab_threshold < $data/$corpus.truecased.$trg > $data/$corpus.bpe.$trg
done

# sizes
echo "Sizes of all files:"

wc -l $sub_data/*

# sanity checks
echo "At this point, please make sure that 1) number of lines are as expected, 2) language suffixes are correct and 3) files are parallel"
