#!/bin/bash

HOST=`hostname`
ROUND=$1
EXTENSION=`printf "round%02d" $ROUND`
EXPERIMENT=experiment_gspca_te
METHODS='pca'
CLASSIFIERS='svm'
for CLASSIFIER in $CLASSIFIERS; do
  for M in $METHODS; do
    OUTPUTFILE="results/neurocom/$HOST.tennessee.$CLASSIFIER.$M.$EXTENSION"; echo $OUTPUTFILE;
    METHOD=feature_selection_$M
    echo bash matlab.bash \<\<\< "setenv('LC_ALL','C'); $EXPERIMENT, quit\"" \> $OUTPUTFILE > $OUTPUTFILE
    bash matlab.bash <<< "setenv('LC_ALL','C'); $EXPERIMENT, quit" >> $OUTPUTFILE
  done
done

