#!/bin/bash
DATASETS="$1"
SEEDS="$3"
CLASSIFIERS="$4"
METHODS="$5"
NUMSCLA="$6"
if [ $# -ge 7 ]; then
  AUTOTUNNING=$7
else
  AUTOTUNNING=false
fi
if [ $# -ge 8 ]; then
  EXPERIMENT=$8
else
  EXPERIMENT='experiment_round'
fi

#### Feature Selection Methods ####
for METHOD in $METHODS; do echo "*** $METHOD ***"

#### Number of Classifiers ####
for NUMCLA in $NUMSCLA; do echo "# $NUMCLA Classifiers"

#### Classifier ####
for CLASSIFIER in $CLASSIFIERS; do echo "%%% $CLASSIFIER %%%"

#### Datasets ####
for DATASET in $DATASETS; do echo $DATASET

#### Seeds ####|
for SEED in $SEEDS; do echo "       seed $SEED"
EXTENSION="$2$SEED"

if [ "$METHOD" == "none" ] && [ $NUMCLA -eq 01 ] || [ "$METHOD" == "all" ] && [ $NUMCLA -eq 01 ] || [ "$METHOD" != "none" ] ; then
  M=${METHOD/\(/-}
  M=${M/\)/}
  OUTPUTFILE='results/'${DATASET/*\//}-${EXPERIMENT}-${M}-${NUMCLA}${CLASSIFIER}-at${AUTOTUNNING}.${EXTENSION}; echo $OUTPUTFILE;
  echo bash matlab.bash \<\<\< "\"$EXPERIMENT('datasets/$DATASET', '$CLASSIFIER', '$METHOD', $NUMCLA, $SEED, $AUTOTUNNING), quit\"" \> $OUTPUTFILE > $OUTPUTFILE
  bash matlab.bash <<< "setenv('LC_ALL','C'); $EXPERIMENT('datasets/$DATASET', '$CLASSIFIER', '$METHOD', $NUMCLA, $SEED, $AUTOTUNNING), quit" >> $OUTPUTFILE
fi

done
done
done
done
done
