#!/bin/bash

rm /tmp/round.txt
for i in ${1}*[^csv]; do
  ROUND=${i:(-2)}
  NLINES=`cat $i | grep confold | wc -l`
  printf "%0.s${ROUND}\n" `seq 1 $NLINES` >> /tmp/round.txt
done
cat ${1}*[^csv] | grep confold | cut -d ':' -f 2- > /tmp/conf.txt
COLUMNS=`tail -n 1 /tmp/conf.txt | tr "," "\n" | wc -l`
paste /tmp/round.txt /tmp/conf.txt | tr '\t' ',' > /tmp/confs.txt
printf "Round, Fold" > /tmp/header.txt
printf ",label%s " `seq 1 $((COLUMNS-1))` >> /tmp/header.txt
printf "\n" >> /tmp/header.txt
cat /tmp/header.txt /tmp/confs.txt > ${1}.confusion.csv

