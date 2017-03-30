#!/bin/bash
rm feats.*
for i in *.genetic.[ft]*; do bash getfeatures.bash $i >> feats.1ga; done
for i in *.cascade_hybridranking_genetic.[ft]*; do bash getfeatures.bash $i >> feats.2rg; done
for i in *.cascade_hybridsfs_genetic.[ft]*; do bash getfeatures.bash $i >> feats.3sg; done
for i in *.cascade_hybridranking_hybridsfs_genetic.[ft]*; do bash getfeatures.bash $i >> feats.4rsg; done

rm featsintersec.*
rm featsunion.*
for i in feats.*; do
  for d in {01..21}; do
    FIRSTLINE=`cat $i | grep d$d | head -n 1`
    INTERSECTION=""
    NL=`cat $i | grep d$d | wc -l | cut -d ' ' -f 1`
    for f in $FIRSTLINE; do
      F=`cat $i | grep d$d | grep $f | wc -l | cut -d ' ' -f 1`
      if [ $F -eq $NL ]; then
        INTERSECTION=${INTERSECTION}" "$f
      fi
    done
    INTERSECTION=`echo $INTERSECTION | tr ' ' '\n' | sort -g | tr '\n' ' '`
    echo $INTERSECTION >> ${i/feats/featsintersec}
    cat $i | grep d$d | cut -d ' ' -f2- | tr ' ' '\n' | sort -n | uniq | wc -l >> ${i/feats/featsunion}
  done
done
for d in {01..21}; do
  LINE="d${d}"
  for i in featsintersec.*; do
    FEATS=`cat $i | grep d$d`
    LINE=$LINE" & "${FEATS:4}
  done
  echo $LINE" \\\\" >> feats.all
done

