#!/bin/bash

DIR=$1
if [ -e $DIR/code.R ] ; then rm $DIR/code.R; fi
AUX="c("
AT="c("
T=""
N=0
for FILE in `ls $DIR/*.csv | grep confusion -v`; do
  N=$((N+1))
  echo "t$N <- c(as.matrix(read.table(\"$FILE\", sep=\";\", quote=\"\\\"\")[,-11]))" >> $DIR/code.R
  AUX=${AUX}\"$N\",
  AT=${AT}$N,
  T=$T"t${N},"
done
T=${T::-1}
AUX=${AUX::-1}")"
AT=${AT::-1}")"
echo "" >> $DIR/code.R
echo "auxmethods = "$AUX >> $DIR/code.R
echo "" >> $DIR/code.R
echo "pdf(\"$DIR/boxplot.pdf\")" >> $DIR/code.R
printf "boxplot("${T}",xatx=\"n\",ylab=\"F-Measure\",xlab=\"Methods\")\n" >> $DIR/code.R
echo "axis(1,at=$AT,labels=auxmethods,cex.axis=0.75)" >> $DIR/code.R
echo "M = cbind("$T")" >> $DIR/code.R
echo "colnames(M) <- auxmethods" >> $DIR/code.R
echo "apply(M,2,summary)" >> $DIR/code.R
echo "" >> $DIR/code.R
echo "pdf(\"$DIR/lines1.pdf\")" >> $DIR/code.R
echo "plot(M[1,],type=\"l\",ylim=range(M),xaxt=\"n\",xlab=\"Method\",ylab=\"F-Measure\")" >> $DIR/code.R
echo "axis(1,at=$AT,labels=auxmethods)" >> $DIR/code.R
NF=`wc -w $FILE | cut -d ' ' -f 1`
echo "for(i in 2:$NF){" >> $DIR/code.R
echo "  lines(M[i,])" >> $DIR/code.R
echo "}" >> $DIR/code.R

echo "P = apply(M,2,quantile,probs=c(.1,.5,.9))" >> $DIR/code.R
echo "pdf(\"$DIR/lines2.pdf\")" >> $DIR/code.R
echo "plot(P[1,],type=\"l\",ylim=range(M),xaxt=\"n\",xlab=\"Method\",ylab=\"F-Measure\",lty=2)" >> $DIR/code.R
echo "axis(1,at=$AT,labels=auxmethods)" >> $DIR/code.R
echo "lines(P[2,])" >> $DIR/code.R
echo "lines(P[3,],lty=2)" >> $DIR/code.R

STRING="R = matrix(0,dim(M)[2],dim(M)[2])
for(i in 1:(dim(M)[2]-1)){
   for(j in (i+1):dim(M)[2]){
     d = M[,i]-M[,j]
     TC = mean(d) / sqrt(var(d)*(1/length(d) + 1/9))
     p = 2*(1-pt(abs(TC),99))
     R[i,j] = TC
     R[j,i] = p
   }
}
R"
printf "$STRING\n" >> $DIR/code.R

STRING="panel.plot <- function(x, y) {
  usr <- par(\"usr\"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1),xaxt=\"n\",yaxt=\"n\")
  d = x - y
  TC = mean(d) / (sqrt(var(d)*(1/length(d) + 1/9)))
  ct <- 2*(1-pt(abs(TC),99))
  r <- ct
  rt = ct
  tp =2 
  if(rt > 0.008) tp = 1
  text(.5, .5, format(rt,digits=4),cex=1,font=tp)
}
panel.smooth <- function (x, y) {
   a = 1:$NF
   d = x-y  
   usr <- par(\"usr\"); on.exit(par(usr))
   par(xaxt=\"n\",yaxt=\"n\")  
   par(new=T);hist(d,main=\"\",xlim=c(-max(abs(d)),max(abs(d)))) 
   abline(v=0,lwd=2.5) 
   if(par('mfg')[2] == 1) axis(2) 
   if(par('mfg')[1] == ncol(M)) axis(1) 
}
MN = M[,$AT]"

printf "$STRING\n" >> $DIR/code.R

STRING="pdf(\"$DIR/matrix.pdf\")
par(xaxt=\"n\",yaxt=\"n\")  
pairs(M, lower.panel= panel.smooth, upper.panel=panel.plot,font.labels = 1,cex.labels = 1.2)"
printf "$STRING\n" >> $DIR/code.R

echo "" >> $DIR/code.R
echo "################# Confusion matrix analisys " >> $DIR/code.R
echo "pdf(\"$DIR/confusion.pdf\")" >> $DIR/code.R

M=""
N=0
for FILE in `ls $DIR/*.csv | grep confusion`; do
  N=$((N+1))
  #echo "m$N <- c(as.matrix(read.table(\"$FILE\", sep=\";\", quote=\"\\\"\")[,-11]))" >> $DIR/code.R
  echo "m$N <- read.csv(\"$FILE\")" >> $DIR/code.R
  M=$M"m${N},"
done
M=${M::-1}

NC=`wc -l $FILE | cut -d ' ' -f 1`
NC=$((NC/NF))
STRING="comp_matrix_conf <- function(M){
    aux <- matrix(0,$NC,$NC)
    for(i in 1:$NF){ 
          aux <- aux + M[((i-1)*$NC + 1): (i*$NC),-c(1,2) ]
    }
    return(as.table(as.matrix(aux)))  
}"
echo "$STRING" >> $DIR/code.R

for i in `seq 1 $N`; do
  echo "cm$i <- comp_matrix_conf(m$i)" >> $DIR/code.R
  echo "cm$i" >> $DIR/code.R
done

echo "" >> $DIR/code.R
echo "######## Percentage of coreect multiclass classifications" >> $DIR/code.R

echo "perc_global <- function(M){return(sum(diag(M))/sum(M))}" >> $DIR/code.R
PG=''
for i in `seq 1 $N`; do
  echo "pg$i=perc_global(cm$i)" >> $DIR/code.R
  PG=${PG}pg$i,
done
PG=${PG::-1}
echo "plot(c($PG),type=\"b\",ylab=\"Accuracy\",xaxt=\"n\",xlab=\"Method\")" >> $DIR/code.R
echo "axis(1,at=$AT,labels=auxmethods)" >> $DIR/code.R

echo "" >> $DIR/code.R
echo "### recall" >> $DIR/code.R
echo "rec <- function(M){return(diag(prop.table(M,1)))}" >> $DIR/code.R
REC=''
for i in `seq 1 $N`; do
  echo "rec$i=rec(cm$i)" >> $DIR/code.R
  REC=${REC}rec$i,
done
REC=${REC::-1}

ATL=''
LABELS='c('
for i in `seq 1 $NC`; do
  ATL=$ATL$i,
  LABELS=$LABELS\"$i\",
done
ATL=${ATL::-1}
LABELS=${LABELS::-1}')'

echo "plot(rec1,type=\"l\",ylim=range($REC),ylab=\"Recall\",xaxt=\"n\",xlab=\"Category\")" >> $DIR/code.R
for i in `seq 2 $N`; do
  echo "points(rec$i,pch=19,type=\"l\",col=$i)" >> $DIR/code.R
done
echo "auxlabels = $LABELS" >> $DIR/code.R
echo "axis(1,at=c($ATL),labels=auxlabels)" >> $DIR/code.R
TMP=`seq 1 $N`
TMP=`printf "%0.s1," $TMP`
TMP=${TMP::-1}
echo "legend(1,0.7,legend=auxmethods,col=$AT,lty=c($TMP))" >> $DIR/code.R

echo "" >> $DIR/code.R
echo "#### Simplifying: considering normal vs. failure" >> $DIR/code.R
echo "simplematrix <- function(M){
   aux <- rbind(c(M[1,1],sum(M[1,])-M[1,1]),
   c((sum(M[,1])-M[1,1]), sum(M[-1,-1])))
   return(aux)
}" >> $DIR/code.R

for i in `seq 1 $N`; do
  echo "norm$i <- simplematrix(cm$i)" >> $DIR/code.R
done
PG=''
for i in `seq 1 $N`; do
  echo "pg$i <- perc_global(norm$i)" >> $DIR/code.R
  PG=${PG}pg$i,
done
PG=${PG::-1}

echo "plot(c($PG),type=\"b\",ylab=\"Accuracy\",xaxt=\"n\",xlab=\"Method\")" >> $DIR/code.R
echo "axis(1,at=$AT,labels=auxmethods)" >> $DIR/code.R
for i in `seq 1 $N`; do
  echo "rec$i <- rec(norm$i)" >> $DIR/code.R
done

echo "plot(rec1,type=\"l\",ylim=range($REC),ylab=\"Recall\",xaxt=\"n\",xlab=\"Category\")" >> $DIR/code.R
for i in `seq 2 $N`; do
  echo "points(rec$i,pch=19,type=\"l\",col=$i)" >> $DIR/code.R
done
echo "axis(1,at=c(1,2),labels=c(\"Normal\",\"Faulty\"))" >> $DIR/code.R
echo "legend(1,0.95,legend=auxmethods,col=$AT,lty=c($TMP))" >> $DIR/code.R

