#!/bin/bash

cat ${1}[^.]* | grep 'fold-..:' | grep -v feats-fold > /tmp/folds.txt
FOLDS=`cut -d ' ' -f 1  /tmp/folds.txt | sort -r | uniq`
if [ -e table.csv ]; then rm table.csv; fi
touch table.csv
for i in $FOLDS; do
  cat /tmp/folds.txt | grep $i | cut -d ":" -f 2 > /tmp/fold.txt
  mv table.csv /tmp
  paste /tmp/fold.txt /tmp/table.csv > table.csv
done
sed -i -e 's/\t/; /g' table.csv
mv table.csv ${1}.csv

