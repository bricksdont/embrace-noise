#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill

MOSES=$base/tools/moses-scripts/scripts

sed -r 's/&amp; quot ;/\&quot;/g' | sed -r 's/&amp; apos ;/\&apos;/g' | \
$MOSES/tokenizer/detokenizer.perl -l en
