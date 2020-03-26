#! /bin/bash

base=/net/cephfs/home/mathmu/scratch/noise-distill
scripts=$base/scripts

MOSES=$base/tools/moses-scripts/scripts

data=$base/data

src=de
trg=en

mkdir -p $data

mkdir -p $data/raw

for corpus in train dev test; do
  mkdir -p $data/raw/$corpus
done

# training data

if [[ ! -f $data/khayrallah_koehn2018_noise_data.tgz ]]; then
  wget -N http://data.statmt.org/noise/khayrallah_koehn2018_noise_data.tgz -P $data
fi

if [[ ! -d $data/khayrallah+koehn2018_noise_data ]]; then
  tar -xzvf $data/khayrallah_koehn2018_noise_data.tgz -C $data
fi
cp $data/khayrallah+koehn2018_noise_data/data/* $data/raw/train

# remove zip file because quite big (5 GB)

# rm $data/khayrallah_koehn2018_noise_data.tgz
# rm -r $data/khayrallah+koehn2018_noise_data

# dev data

wget --content-disposition http://matrix.statmt.org/test_sets/newstest2016.tgz -P $data
tar -xzvf $data/newstest2016.tgz -C $data

for file in $data/sgm/*; do
  filename=`basename "$file"`
  perl $MOSES/ems/support/input-from-sgm.perl < $file > $data/raw/dev/$filename".txt"
done

rm -r $data/sgm $data/newstest2016.tgz

# test data

wget --content-disposition http://matrix.statmt.org/test_sets/newstest2017.tgz -P $data
tar -xzvf $data/newstest2017.tgz -C $data

for file in $data/test/*; do
  filename=`basename "$file"`
  perl $MOSES/ems/support/input-from-sgm.perl < $file > $data/raw/test/$filename".txt"
done

rm $data/newstest2017.tgz $data/test/*.sgm
rm -r $data/test

# link dev and test files
ln -s $data/raw/dev/newstest2016-$src$trg-src.$src.sgm.txt $data/raw/dev/dev.$src
ln -s $data/raw/dev/newstest2016-$src$trg-ref.$trg.sgm.txt $data/raw/dev/dev.$trg

ln -s $data/raw/test/newstest2017-$src$trg-src.$src.sgm.txt $data/raw/test/test.$src
ln -s $data/raw/test/newstest2017-$src$trg-ref.$trg.sgm.txt $data/raw/test/test.$trg

# look for test in different domain

if [[ -f /net/cephfs/scratch/mathmu/laser-contra/filtered/cs-bulletin.filtered.de-en ]]; then

  head -n 3000 /net/cephfs/scratch/mathmu/laser-contra/filtered/cs-bulletin.filtered.de-en > $data/raw/test_ood/test_ood.both

  cut -f1 $data/raw/test_ood/test_ood.both > $data/raw/test_ood/test_ood.$src
  cut -f2 $data/raw/test_ood/test_ood.both > $data/raw/test_ood/test_ood.$trg
fi

# sizes
echo "Sizes of all files:"

wc -l $data/raw/*/*

# sanity checks
echo "At this point, please make sure that 1) number of lines are as expected, 2) language suffixes are correct and 3) files are parallel"
