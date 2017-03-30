#!/bin/bash
DATASETS=$1
SEED=$2
BASECLASSIFIER=$3
DIRRESULT=results
EXTENSION='re'
EXPERIMENT='experiment_re' 
echo $EXPERIMENT
PROPS='0.5 0.75 0.875 0.95 1'
NUMSCLA='01 05 10 20'
for NUMCLA in $NUMSCLA; do 
  for NUMSAMPS in $PROPS; do
    for NUMFEATS in $PROPS; do
      for DATASET in $DATASETS; do #echo $DATASET
        OUTPUTFILE="$DIRRESULT/${DATASET/*\//}-${EXPERIMENT}-${NUMCLA}${BASECLASSIFIER}${NUMSAMPS}s${NUMFEATS}f.$EXTENSION"; echo $OUTPUTFILE
        echo bash matlab.bash \<\<\< "\"setenv('LC_ALL','C'); $EXPERIMENT('datasets/$DATASET', '${BASECLASSIFIER}' , ${NUMCLA} , ${NUMSAMPS} , ${NUMFEATS}, $SEED), quit\"" \> $OUTPUTFILE > $OUTPUTFILE
        bash matlab.bash <<< "setenv('LC_ALL','C'); $EXPERIMENT('datasets/$DATASET', '${BASECLASSIFIER}' , ${NUMCLA} , ${NUMSAMPS} , ${NUMFEATS}, $SEED), quit" >> $OUTPUTFILE
        tail -n 1 $OUTPUTFILE
      done
    done
  done
done
