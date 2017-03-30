t1 <- c(as.matrix(read.table("test/cwru7u-experiment_cwru-none-01elm-atfalse.txt.csv", sep=";", quote="\"")[,-11]))
t2 <- c(as.matrix(read.table("test/cwru7u-experiment_cwru-none-01knn-atfalse.txt.csv", sep=";", quote="\"")[,-11]))
t3 <- c(as.matrix(read.table("test/cwru7u-experiment_cwru-ranking-fscriterion_filter-01knn-atfalse.txt.csv", sep=";", quote="\"")[,-11]))

auxmethods = c("ELM","KNN","KNN-FS")

pdf("test/boxplot.pdf")
boxplot(t1,t2,t3,xatx="n",ylab="F-Measure",xlab="Methods")
axis(1,at=c(1,2,3),labels=auxmethods,cex.axis=0.75)
M = cbind(t1,t2,t3)
M = M[1:40,]
colnames(M) <- auxmethods
apply(M,2,summary)

pdf("test/lines1.pdf")
plot(M[1,],type="l",ylim=range(M),xaxt="n",xlab="Method",ylab="F-Measure")
axis(1,at=c(1,2,3),labels=auxmethods)
for(i in 2:40){
  lines(M[i,])
}
P = apply(M,2,quantile,probs=c(.1,.5,.9))
pdf("test/lines2.pdf")
plot(P[1,],type="l",ylim=range(M),xaxt="n",xlab="Method",ylab="F-Measure",lty=2)
axis(1,at=c(1,2,3),labels=auxmethods)
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
   a = 1:40
   d = x-y  
   usr <- par("usr"); on.exit(par(usr))
   par(xaxt="n",yaxt="n")  
   par(new=T);hist(d,main="",xlim=c(-max(abs(d)),max(abs(d)))) 
   abline(v=0,lwd=2.5) 
   if(par('mfg')[2] == 1) axis(2) 
   if(par('mfg')[1] == ncol(M)) axis(1) 
}
MN = M[,c(1,2,3)]
pdf("test/matrix.pdf")
par(xaxt="n",yaxt="n")  
pairs(M, lower.panel= panel.smooth, upper.panel=panel.plot,font.labels = 1,cex.labels = 1.2)

################# Confusion matrix analisys 
pdf("test/confusion.pdf")
m1 <- read.csv("test/cwru7u-experiment_cwru-none-01elm-atfalse.txt.confusion.csv")
m2 <- read.csv("test/cwru7u-experiment_cwru-none-01knn-atfalse.txt.confusion.csv")
m3 <- read.csv("test/cwru7u-experiment_cwru-ranking-fscriterion_filter-01knn-atfalse.txt.confusion.csv")
comp_matrix_conf <- function(M){
    aux <- matrix(0,7,7)
    for(i in 1:40){ 
          aux <- aux + M[((i-1)*7 + 1): (i*7),-c(1,2) ]
    }
    return(as.table(as.matrix(aux)))  
}
cm1 <- comp_matrix_conf(m1)
cm1
cm2 <- comp_matrix_conf(m2)
cm2
cm3 <- comp_matrix_conf(m3)
cm3

######## Percentage of coreect multiclass classifications
perc_global <- function(M){return(sum(diag(M))/sum(M))}
pg1=perc_global(cm1)
pg2=perc_global(cm2)
pg3=perc_global(cm3)
plot(c(pg1,pg2,pg3),type="b",ylab="Accuracy",xaxt="n",xlab="Method")
axis(1,at=c(1,2,3),labels=auxmethods)

### recall
rec <- function(M){return(diag(prop.table(M,1)))}
rec1=rec(cm1)
rec2=rec(cm2)
rec3=rec(cm3)
plot(rec1,type="l",ylim=range(rec1,rec2,rec3),ylab="Recall",xaxt="n",xlab="Category")
points(rec2,pch=19,type="l",col=2)
points(rec3,pch=19,type="l",col=3)
auxlabels = c("1","2","3","4","5","6","7")
axis(1,at=c(1,2,3,4,5,6,7),labels=auxlabels)
legend(1,0.7,legend=auxmethods,col=c(1,2,3),lty=c(1,1,1))

#### Simplifying: considering normal vs. failure
simplematrix <- function(M){
   aux <- rbind(c(M[1,1],sum(M[1,])-M[1,1]),
   c((sum(M[,1])-M[1,1]), sum(M[-1,-1])))
   return(aux)
}
norm1 <- simplematrix(cm1)
norm2 <- simplematrix(cm2)
norm3 <- simplematrix(cm3)
pg1 <- perc_global(norm1)
pg2 <- perc_global(norm2)
pg3 <- perc_global(norm3)
plot(c(pg1,pg2,pg3),type="b",ylab="Accuracy",xaxt="n",xlab="Method")
axis(1,at=c(1,2,3),labels=auxmethods)
rec1 <- rec(norm1)
rec2 <- rec(norm2)
rec3 <- rec(norm3)
plot(rec1,type="l",ylim=range(rec1,rec2,rec3),ylab="Recall",xaxt="n",xlab="Category")
points(rec2,pch=19,type="l",col=2)
points(rec3,pch=19,type="l",col=3)
axis(1,at=c(1,2),labels=c("Normal","Faulty"))
legend(1,0.95,legend=auxmethods,col=c(1,2,3),lty=c(1,1,1))
