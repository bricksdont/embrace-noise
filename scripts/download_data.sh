#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

MOSES=$base/tools/moses-scripts/scripts

data=$base/data

src=de
trg=en

mkdir -p $data

mkdir -p $data/train $data/dev $data/test

mkdir -p $data/train/raw

# training data

if [[ ! -f $data/khayrallah_koehn2018_noise_data.tgz ]]; then
  wget -N http://data.statmt.org/noise/khayrallah_koehn2018_noise_data.tgz -P $data
fi

if [[ ! -d $data/khayrallah+koehn2018_noise_data ]]; then
  tar -xzvf $data/khayrallah_koehn2018_noise_data.tgz -C $data
fi
mv $data/khayrallah+koehn2018_noise_data/data/* $data/train/raw

# remove zip file because quite big (5 GB)

rm $data/khayrallah_koehn2018_noise_data.tgz
rm -r $data/khayrallah+koehn2018_noise_data

# dev data

wget --content-disposition http://matrix.statmt.org/test_sets/newstest2016.tgz -P $data
tar -xzvf $data/newstest2016.tgz -C $data

for file in $data/sgm/*; do
  filename=`basename "$file"`
  perl $MOSES/ems/support/input-from-sgm.perl < $file > $data/dev/$filename".txt"
done

rm -r $data/sgm $data/newstest2016.tgz

# test data

wget --content-disposition http://matrix.statmt.org/test_sets/newstest2017.tgz -P $data
tar -xzvf $data/newstest2017.tgz -C $data

for file in $data/test/*; do
  filename=`basename "$file"`
  perl $MOSES/ems/support/input-from-sgm.perl < $file > $data/test/$filename".txt"
done

rm $data/newstest2017.tgz $data/test/*.sgm

# link dev and test files
ln -s $data/dev/newstest2016-$src$trg-src.$src.sgm.txt $data/dev/dev.$src
ln -s $data/dev/newstest2016-$src$trg-ref.$trg.sgm.txt $data/dev/dev.$trg

ln -s $data/test/newstest2017-$src$trg-src.$src.sgm.txt $data/test/test.$src
ln -s $data/test/newstest2017-$src$trg-ref.$trg.sgm.txt $data/test/test.$trg

# sizes
echo "Sizes of all files:"

wc -l $data/*/*/*

# sanity checks
echo "At this point, please make sure that 1) number of lines are as expected, 2) language suffixes are correct and 3) files are parallel"
