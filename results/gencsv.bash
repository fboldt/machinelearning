#!/bin/bash

FILES=""
for i in $@; do
  FILES=$FILES${i::-2}'\n'
done
for i in `printf $FILES | sort | uniq`; do
  bash gencsvfold.bash $i
  bash gencsvconf.bash $i
done

