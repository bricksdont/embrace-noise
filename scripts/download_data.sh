#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$base/data

mkdir -p $data

wget -N http://data.statmt.org/noise/khayrallah_koehn2018_noise_data.tgz -P $data

tar -xzvf $data/khayrallah_koehn2018_noise_data.tgz -C $data

mkdir $data/train

mv $data/khayrallah+koehn2018_noise_data/data $data/train

# remove zip file because quite big (5 GB)
rm $data/khayrallah_koehn2018_noise_data.tgz

# sizes
echo "Sizes of all files:"

wc -l $data/*/*

# sanity checks
echo "At this point, please make sure that 1) number of lines are as expected, 2) language suffixes are correct and 3) files are parallel"
