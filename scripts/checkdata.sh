#!/bin/sh

# This script runs the stemmer for each language for which a sample vocabulary
# is found, generating the diffs file for that langauge.

STEMWORDS='../snowball/stemwords'

if [ ! -x $STEMWORDS ]
then
  echo "Can't find \"stemwords\" executable."
  exit 1
fi

cd ../data
datalangs=`find * -type d -maxdepth 0 -not -name .svn`

for lang in $datalangs
do
  echo "Checking $lang..."
  $STEMWORDS -l $lang -i ../data/$lang/voc.txt -o ../data/$lang/output.txt
done
