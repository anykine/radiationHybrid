# group the cis by gene

cis = read.table("cis_with_pos.txt")
names(cis) <- c("chrom", "start", "stop", "symbol", "index", "marker", "mu", "alpha", "nlp")

stderr = function(vals){
  return(sd(vals)/sqrt(length(vals)))
}

# plot TCGA cis by chrom
plotalphas = function(cis=cis, title=TRUE){
  data = matrix('NA', 24,2)
  for (i in 1:24){
    idx = cis[,1]==i
    data[i,1] = mean(cis[idx,8])
    data[i,2] = sd(cis[idx,8])/sqrt(length(idx))
  }
  labels = seq(1:24)
  #plot
  #pdf(file="cisalpha_bychrom_tcga.pdf")
  bp = barplot(as.numeric(data[,1]), names.arg = labels, ylim=c(0,1.0), xlab="chrom", ylab="mean alpha")
  for (i in 1:length(bp)){
    arrows(bp[i], as.numeric(data[i,1])-as.numeric(data[i,2]), bp[i], as.numeric(data[i,1])+as.numeric(data[i,2]), angle=90, code=3, length=0.01)
  }
  if (title==TRUE){
    title("mean cis alphas by chromosome for TCGA-GBM")
  }
  #dev.off()
}

# plot TCGA cis by chrom separately for pos/neg cis alphas
plotBySign = function(cis=cis, title=TRUE, titles){
  #data = matrix('NA', 24,4)
  data = data.frame("meanall"=rep(0,24), "sdall"=rep(0,24), "meannegs"=rep(0,24), "sdnegs"=rep(0,24), "meanpos"=rep(0,24), "sdpos"=rep(0,24))
  for (i in 1:24){
    idx = which(cis[,1]==i)
    data[i,1] = mean(cis[idx,7])
    data[i,2] = sd(cis[idx,7])/sqrt(length(idx))
    negs = which(cis[idx,7]<0)
    pos  = which(cis[idx,7]>0)
    negs1 = idx[negs]
    pos1 = idx[pos]
    data[i,3] = mean(abs(cis[negs1,7]))
    data[i,4] = sd(abs(cis[negs1,7]))/sqrt(length(cis[negs1,7]))
    data[i,5] = mean(cis[pos1,7])
    data[i,6] = sd(abs(cis[pos1,7]))/sqrt(length(cis[pos1,7]))
  }
  labels = seq(1:24)
  #plot
  #pdf(file="cisalpha_bychrom_tcga.pdf")
  par(mfrow=c(1,2))
  bp = barplot(as.numeric(data[,3]), names.arg = labels, ylim=c(0,1.5), xlab="chrom", ylab="mean alpha")
  for (i in 1:length(bp)){
    arrows(bp[i], as.numeric(data[i,3])-as.numeric(data[i,4]), bp[i], as.numeric(data[i,3])+as.numeric(data[i,4]), angle=90, code=3, length=0.01)
  }
  if (title==TRUE){
    title("mean cis alphas\n for neg cis alphas in TCGA-GBM")
  } else {
    title(titles[1])
  }
  bp = barplot(as.numeric(data[,5]), names.arg = labels, ylim=c(0,1.5), xlab="chrom", ylab="mean alpha")
  for (i in 1:length(bp)){
    arrows(bp[i], as.numeric(data[i,5])-as.numeric(data[i,6]), bp[i], as.numeric(data[i,5])+as.numeric(data[i,6]), angle=90, code=3, length=0.01)
  }
  if (title==TRUE){
    title("mean cis alphas\n for pos cis alphas in TCGA-GBM")
  } else {
    title(titles[2])
  }
  #dev.off()
  return(data)
}

# plot cis alpha for male/female
plotCisByGender <- function(){
  femalecis = read.table("female_cis_with_pos.txt")
  names(femalecis) <- c("chrom", "start", "stop", "symbol", "index", "marker", "mu", "alpha", "nlp")
  par(mfrow=c(2,1))
  plotalphas(femalecis, title=FALSE)
  title("mean cis alphas, TCGA-GBM, female")
  malecis = read.table("male_cis_with_pos.txt")
  plotalphas(malecis, title=FALSE)
  title("mean cis alphas, TCGA-GBM, male")
}

# plot cis alpha for male/female by +/- alpha
plotCisByGenderSplit <- function() {
  pdf(file="sex_cis_split_alpha.pdf")
  femalecis = read.table("female_cis_with_pos.txt")
  names(femalecis) <- c("chrom", "start", "stop", "symbol", "index", "marker", "mu", "alpha", "nlp")
  par(mfrow=c(2,2))
  fres=plotBySign(femalecis, title=FALSE,
    c("female TCGA-GBM neg alpha", "female TCGA-GBM pos alpha")
  )

  x11()
  malecis = read.table("male_cis_with_pos.txt")
  names(malecis) <- c("chrom", "start", "stop", "symbol", "index", "marker", "mu", "alpha", "nlp")
  mres = plotBySign(malecis, title=FALSE,
    c("male TCGA-GBM neg alpha", "male TCGA-GBM pos alpha"))
  dev.off()
}
####### RUN #########3
#plotalphas()
#plotBySign()

#### scratch ###
#male pos alpha does not show 1/2 cis effect size
malecis = read.table("male_cis_with_pos.txt")
femalecis = read.table("female_cis_with_pos.txt")
chroms = factor(malecis[,1])
m.means = tapply(malecis[,8], chroms, mean)
m.pos = which(malecis[,8]>0)
m.pos.means = tapply(malecis[m.pos,8], factor(malecis[m.pos,1]), mean)
m.pos.median = tapply(malecis[m.pos,8], factor(malecis[m.pos,1]), median)
f.means = tapply(femalecis[,8], chroms, mean)
f.pos = which(femalecis[,8]>0)
f.pos.means = tapply(femalecis[f.pos,8], factor(femalecis[f.pos,1]), mean)
chrX = which(malecis[,1]==23)
mhists = tapply(malecis[,8], chroms, hist,breaks=100)
fhists = tapply(femalecis[,8], chroms, hist, breaks=100)
#pdf(file="test.pdf")
par(mfrow=c(3,2))
for (i in 1:24){
  plot(mhists[[i]], xlim=c(-1,1), col="blue", freq=F, breaks=20)
  #plot(fhists[[i]], xlim=c(-1,1), col="pink", freq=F, breaks=20)
}
#dev.off()

#find the x genes in common to M and F
