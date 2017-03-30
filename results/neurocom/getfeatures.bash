#!/bin/bash
FILE=$1
LINES=(`cat -n $FILE | grep 'used_features\|numfeats\ =' | sed -e 's/ //g' | cut -f 1`)
NCLASSES=`echo ${#LINES[@]}/2 | bc`
for i in `seq 0 2 $((${#LINES[@]}-1))`; do
  IL=${LINES[i]} 
  printf "d%02d " $((i/2+1))
  IL=$((IL+2))
  FEATS=""
  while [ $IL -le ${LINES[((i+1))]} ]; do
    FEATS=$FEATS`sed -n ${IL}p $FILE | grep -v Column`
    IL=$((IL+2))
  done
  echo $FEATS
done

