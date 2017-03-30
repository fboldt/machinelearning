#!/bin/bash
cat results/neurocom/hestia.experiment_fs_te3.elm\(10\).cascade_hybridranking_genetic.fste?? | grep _te.m |  sed -e 's/_te.m//g' > results/neurocom/rg.txt;
cat results/neurocom/hestia.experiment_fs_te3.elm\(10\).cascade_hybridranking_hybridsfs_genetic.fste?? | grep _te.m |  sed -e 's/_te.m//g' > results/neurocom/rsg.txt
cat `ls -tr results/neurocom/*.experiment_fs_te3.elm\(10\).genetic.fste??` | grep _te.m |  sed -e 's/_te.m//g' > results/neurocom/ga.txt;
cat results/neurocom/hestia.experiment_fs_te3.elm\(10\).cascade_hybridsfs_genetic.fste?? | grep _te.m |  sed -e 's/_te.m//g' > results/neurocom/sg.txt;

