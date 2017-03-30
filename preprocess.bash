#!/bin/bash
fullfile=$1
dirdest="."
if [ $# -lt 1 ]; then echo "Use: bash $0 tooldiagdatafile [dirdest]"; exit; fi
if [ $# -ge 2 ]; then dirdest=$2; fi
filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="$dirdest/${filename%.*}"
grep -v '^$' $fullfile > $filename.m
COLS=`head -1 $filename.m`
COLS=( $COLS )
if [ ${#COLS[@]} -eq 1 ]
then
  LINES=`wc -l $fullfile | cut -f1 -d' '`
  tail -`echo $((LINES -1))` $fullfile | grep -v '^$' >  $filename.m
fi
sed -i -e 's/ /\t/g' $filename.m
sed -i -e 's/,/\t/g' $filename.m
sed -i -e 's/;/\t/g' $filename.m
while [ `grep $'\t\t' $filename.m | wc -l ` -ne 0 ] 
do
  sed -i -e 's/\t\t/\t/g' $filename.m
done
nsamp=`wc -l $filename.m | cut -f1 -d' '`
COLS=`head -1 $filename.m`
COLS=( $COLS )
COLS=${#COLS[@]}
cut -f$COLS $filename.m | sort | uniq > $filename.lab
nlab=`wc -l $filename.lab | cut -d' ' -f1`
for i in `seq 1 $nlab` 
do
  label=`head -$i $filename.lab | tail -1`
  number=`echo $i`
  sed -i -e "s/$label/$number/g" $filename.m
done
