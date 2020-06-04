#! /bin/bash

# calling script needs to set

# $name
# $data
# $data_sub
# $translations_sub
# $evaluations_sub

trg=en

if [[ $name == "baseline.reverse" ]]; then
  trg=de
fi

for corpus in dev test test_ood; do

    if [[ -s $evaluations_sub/$corpus.bleu ]]; then
      continue
    fi

    # compute case-sensitive BLEU on detokenized data

    cat $translations_sub/$corpus.$trg | sacrebleu $data/raw/$corpus/$corpus.$trg > $evaluations_sub/$corpus.bleu

    echo "$evaluations_sub/$corpus.bleu"
    cat $evaluations_sub/$corpus.bleu

done
