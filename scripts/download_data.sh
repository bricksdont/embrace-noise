#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

MOSES=$base/tools/moses-scripts/scripts

data=$base/data

mkdir -p $data

mkdir $data/train $data/dev $data/test

# training data

if [[ ! -f $data/khayrallah_koehn2018_noise_data.tgz ]]; then
  wget -N http://data.statmt.org/noise/khayrallah_koehn2018_noise_data.tgz -P $data
fi

if [[ ! -d $data/khayrallah+koehn2018_noise_data ]]; then
  tar -xzvf $data/khayrallah_koehn2018_noise_data.tgz -C $data
fi
mv $data/khayrallah+koehn2018_noise_data/data $data/train

# remove zip file because quite big (5 GB)

# TODO: uncomment
# rm $data/khayrallah_koehn2018_noise_data.tgz

# dev data

wget --content-disposition http://matrix.statmt.org/test_sets/newstest2016.tgz -P $data
tar -xzvf newstest2016.tgz -C $data

for file in $data/sgm/*; do
  filename=`basename "$file"`
  perl $MOSES/ems/support/input-from-sgm.perl < $file > $data/dev/$filename
done

rm -r $data/sgm $data/newstest2016.tgz

# test data

wget --content-disposition http://matrix.statmt.org/test_sets/newstest2017.tgz -P $data
tar -xzvf newstest2017.tgz -C $data

for file in $data/test/*; do
  filename=`basename "$file"`
  perl $MOSES/ems/support/input-from-sgm.perl < $file > $data/test/$filename
done

rm -r $data/test $data/newstest2017.tgz

# sizes
echo "Sizes of all files:"

wc -l $data/*/*

# sanity checks
echo "At this point, please make sure that 1) number of lines are as expected, 2) language suffixes are correct and 3) files are parallel"
