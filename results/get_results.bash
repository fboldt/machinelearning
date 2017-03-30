#!/bin/bash

FILE=$1
RLINE=`cat -n $1 | grep results | cut -f 1`
BEGIN=`echo ${RLINE}+4 | bc`
END=`echo ${RLINE}+13 | bc`
sed -n ${BEGIN},${END}p $FILE > /tmp/firstpart
BEGIN=`echo ${RLINE}+17 | bc`
END=`echo ${RLINE}+26 | bc`
sed -n ${BEGIN},${END}p $FILE > /tmp/secondpart
paste /tmp/firstpart /tmp/secondpart | sed -e 's/\t/ /g' | sed -e 's/  / /g' | sed -e 's/  / /g' | sed -e 's/  / /g' | cut -d' ' -f 2-11 | tr ' ' ',' > ${FILE/.result/.fold}

