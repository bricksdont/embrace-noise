#! /bin/bash

# calling script needs to set

# $data_sub
# $translations_sub
# $evaluations_sub

trg=en

for corpus in dev test; do

    # compute case-sensitive BLEU on detokenized data

    cat $translations_sub/$corpus.$trg | sacrebleu $data_sub/$corpus.$trg > $evaluations_sub/$corpus.bleu

    echo "$evaluations_sub/$corpus.bleu"
    cat $evaluations_sub/$corpus.bleu

done
