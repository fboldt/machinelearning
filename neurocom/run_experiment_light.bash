#!/bin/bash
DATASETS="$1"
EXTENSION="$2"
SEED="$3"
CLASSIFIERS="$4"
METHODS="$5"
FSCRITERIA="$6"
NUMSCLA="$7"
if [ $# -ge 8 ]; then
  AUTOTUNNING=$8
else
  AUTOTUNNING=false
fi
EXPERIMENT='experiment_light'
#### Number of Classifiers ####
for NUMCLA in $NUMSCLA; do echo "# $NUMCLA Classifiers"
#### Classifier ####
for CLASSIFIER in $CLASSIFIERS; do echo "%%% $CLASSIFIER %%%"
#### Datasets ####
for DATASET in $DATASETS; do echo $DATASET
#### Feature Selection Methods ####
for METHOD in $METHODS; do echo "*** $METHOD ***"
#### Feature Selection Criteria ####
for FSCRITERION in $FSCRITERIA; do echo "@@@ $FSCRITERION @@@"
if [ "$METHOD" == "none" ] && [ $NUMCLA -eq 01 ] && [ "$FSCRITERION" == "wrapper" ] || [ "$METHOD" != "none" ]; then
  OUTPUTFILE='results/'${DATASET/*\//}-${EXPERIMENT}-${METHOD}-${FSCRITERION}-${NUMCLA}${CLASSIFIER}-at${AUTOTUNNING}.${EXTENSION}; echo $OUTPUTFILE;
  echo bash matlab.bash \<\<\< "\"$EXPERIMENT('datasets/$DATASET', '$CLASSIFIER', '$METHOD', '$FSCRITERION', $NUMCLA, $SEED, $AUTOTUNNING), quit\"" \> $OUTPUTFILE > $OUTPUTFILE
  bash matlab.bash <<< "setenv('LC_ALL','C'); $EXPERIMENT('datasets/$DATASET', '$CLASSIFIER', '$METHOD', '$FSCRITERION', $NUMCLA, $SEED, $AUTOTUNNING), quit" >> $OUTPUTFILE
  tail -n 1 $OUTPUTFILE
fi
done
done
done
done
done
