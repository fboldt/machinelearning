t1 <- c(as.matrix(read.table("bcsalefda/bcsale.m-experiment_round-none-01knn-atfalse.txt.csv", sep=";", quote="\"")[,-11]))
t2 <- c(as.matrix(read.table("bcsalefda/bcsalefda.m-experiment_round-none-01knn-atfalse.txt.csv", sep=";", quote="\"")[,-11]))
t3 <- c(as.matrix(read.table("bcsalefda/bcsalefda.m-experiment_round-ranking-01knn-atfalse.txt.csv", sep=";", quote="\"")[,-11]))
t4 <- c(as.matrix(read.table("bcsalefda/bcsalefda.m-experiment_round-ranking-05knn-atfalse.txt.csv", sep=";", quote="\"")[,-11]))
t5 <- c(as.matrix(read.table("bcsalefda/bcsalefda.m-experiment_round-ranking-10knn-atfalse.txt.csv", sep=";", quote="\"")[,-11]))
t6 <- c(as.matrix(read.table("bcsalefda/bcsalefda.m-experiment_round-ranking-20knn-atfalse.txt.csv", sep=";", quote="\"")[,-11]))

auxmethods = c("KNN","KNN+","KNN+FS","5KNN+FS","10KNN+FS","20KNN+FS")

pdf("bcsalefda/boxplot.pdf")
boxplot(t1,t2,t3,t4,t5,t6,xatx="n",ylab="F-Measure",xlab="Methods")
axis(1,at=c(1,2,3,4,5,6),labels=auxmethods,cex.axis=0.75)
M = cbind(t1,t2,t3,t4,t5,t6)
colnames(M) <- auxmethods
apply(M,2,summary)

pdf("bcsalefda/lines1.pdf")
plot(M[1,],type="l",ylim=range(M),xaxt="n",xlab="Method",ylab="F-Measure")
axis(1,at=c(1,2,3,4,5,6),labels=auxmethods)
for(i in 2:100){
  lines(M[i,])
}
P = apply(M,2,quantile,probs=c(.1,.5,.9))
pdf("bcsalefda/lines2.pdf")
plot(P[1,],type="l",ylim=range(M),xaxt="n",xlab="Method",ylab="F-Measure",lty=2)
axis(1,at=c(1,2,3,4,5,6),labels=auxmethods)
lines(P[2,])
lines(P[3,],lty=2)
R = matrix(0,dim(M)[2],dim(M)[2])
for(i in 1:(dim(M)[2]-1)){
   for(j in (i+1):dim(M)[2]){
     d = M[,i]-M[,j]
     TC = mean(d) / sqrt(var(d)*(1/length(d) + 1/9))
     p = 2*(1-pt(abs(TC),99))
     R[i,j] = TC
     R[j,i] = p
   }
}
R
panel.plot <- function(x, y) {
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1),xaxt="n",yaxt="n")
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
   a = 1:100
   d = x-y  
   usr <- par("usr"); on.exit(par(usr))
   par(xaxt="n",yaxt="n")  
   par(new=T);hist(d,main="",xlim=c(-max(abs(d)),max(abs(d)))) 
   abline(v=0,lwd=2.5) 
   if(par('mfg')[2] == 1) axis(2) 
   if(par('mfg')[1] == ncol(M)) axis(1) 
}
MN = M[,c(1,2,3,4,5,6)]
pdf("bcsalefda/matrix.pdf")
par(xaxt="n",yaxt="n")  
pairs(M, lower.panel= panel.smooth, upper.panel=panel.plot,font.labels = 1,cex.labels = 1.2)

################# Confusion matrix analisys 
pdf("bcsalefda/confusion.pdf")
m1 <- read.csv("bcsalefda/bcsalefda.m-experiment_round-none-01knn-atfalse.txt.confusion.csv")
m2 <- read.csv("bcsalefda/bcsalefda.m-experiment_round-ranking-01knn-atfalse.txt.confusion.csv")
m3 <- read.csv("bcsalefda/bcsalefda.m-experiment_round-ranking-05knn-atfalse.txt.confusion.csv")
m4 <- read.csv("bcsalefda/bcsalefda.m-experiment_round-ranking-10knn-atfalse.txt.confusion.csv")
m5 <- read.csv("bcsalefda/bcsalefda.m-experiment_round-ranking-20knn-atfalse.txt.confusion.csv")
m6 <- read.csv("bcsalefda/bcsale.m-experiment_round-none-01knn-atfalse.txt.confusion.csv")
comp_matrix_conf <- function(M){
    aux <- matrix(0,5,5)
    for(i in 1:100){ 
          aux <- aux + M[((i-1)*5 + 1): (i*5),-c(1,2) ]
    }
    return(as.table(as.matrix(aux)))  
}
cm1 <- comp_matrix_conf(m1)
cm1
cm2 <- comp_matrix_conf(m2)
cm2
cm3 <- comp_matrix_conf(m3)
cm3
cm4 <- comp_matrix_conf(m4)
cm4
cm5 <- comp_matrix_conf(m5)
cm5
cm6 <- comp_matrix_conf(m6)
cm6

######## Percentage of coreect multiclass classifications
perc_global <- function(M){return(sum(diag(M))/sum(M))}
pg1=perc_global(cm1)
pg2=perc_global(cm2)
pg3=perc_global(cm3)
pg4=perc_global(cm4)
pg5=perc_global(cm5)
pg6=perc_global(cm6)
plot(c(pg1,pg2,pg3,pg4,pg5,pg6),type="b",ylab="Accuracy",xaxt="n",xlab="Method")
axis(1,at=c(1,2,3,4,5,6),labels=auxmethods)

### recall
rec <- function(M){return(diag(prop.table(M,1)))}
rec1=rec(cm1)
rec2=rec(cm2)
rec3=rec(cm3)
rec4=rec(cm4)
rec5=rec(cm5)
rec6=rec(cm6)
plot(rec1,type="l",ylim=range(rec1,rec2,rec3,rec4,rec5,rec6),ylab="Recall",xaxt="n",xlab="Category")
points(rec2,pch=19,type="l",col=2)
points(rec3,pch=19,type="l",col=3)
points(rec4,pch=19,type="l",col=4)
points(rec5,pch=19,type="l",col=5)
points(rec6,pch=19,type="l",col=6)
auxlabels = c("Normal","Unbalance","Misalignment","Rubbing","Acc Fault")
axis(1,at=c(1,2,3,4,5),labels=auxlabels)
legend(1,0.7,legend=auxmethods,col=c(1,2,3,4,5,6),lty=c(1,1,1,1,1,1))

#### Simplifying: considering normal vs. failure
simplematrix <- function(M){
   aux <- rbind(c(M[1,1],sum(M[1,])-M[1,1]),
   c((sum(M[,1])-M[1,1]), sum(M[-1,-1])))
   return(aux)
}
norm1 <- simplematrix(cm1)
norm2 <- simplematrix(cm2)
norm3 <- simplematrix(cm3)
norm4 <- simplematrix(cm4)
norm5 <- simplematrix(cm5)
norm6 <- simplematrix(cm6)
pg1 <- perc_global(norm1)
pg2 <- perc_global(norm2)
pg3 <- perc_global(norm3)
pg4 <- perc_global(norm4)
pg5 <- perc_global(norm5)
pg6 <- perc_global(norm6)
plot(c(pg1,pg2,pg3,pg4,pg5,pg6),type="b",ylab="Accuracy",xaxt="n",xlab="Method")
axis(1,at=c(1,2,3,4,5,6),labels=auxmethods)
rec1 <- rec(norm1)
rec2 <- rec(norm2)
rec3 <- rec(norm3)
rec4 <- rec(norm4)
rec5 <- rec(norm5)
rec6 <- rec(norm6)
plot(rec1,type="l",ylim=range(rec1,rec2,rec3,rec4,rec5,rec6),ylab="Recall",xaxt="n",xlab="Category")
points(rec2,pch=19,type="l",col=2)
points(rec3,pch=19,type="l",col=3)
points(rec4,pch=19,type="l",col=4)
points(rec5,pch=19,type="l",col=5)
points(rec6,pch=19,type="l",col=6)
axis(1,at=c(1,2),labels=c("Normal","Faulty"))
legend(1,0.95,legend=auxmethods,col=c(1,2,3,4,5,6),lty=c(1,1,1,1,1,1))
