#! /bin/bash

# calling script needs to set

# $data_sub
# $translations_sub
# $evaluations_sub
# $trg

for corpus in dev test; do

    if [[ -s $evaluations_sub/$corpus.bleu ]]; then
      continue
    fi

    # compute case-sensitive BLEU on detokenized data
    if [[ $trg == "ja" ]]; then
        cat $translations_sub/$corpus.$trg | sacrebleu --tok ja-mecab -l en-ja $data_sub/$corpus.$trg > $evaluations_sub/$corpus.bleu
    else
        cat $translations_sub/$corpus.$trg | sacrebleu $data_sub/$corpus.$trg > $evaluations_sub/$corpus.bleu
    fi

    echo "$evaluations_sub/$corpus.bleu"
    cat $evaluations_sub/$corpus.bleu

done
