# Code to analyze and compare Amon's cis alphas with mouse/human cis alphas.
# This corrects some error in the previous code.

x = read.csv("/media/G3data/fdr18/compare_to_others/amon/1160058TableS1.csv")

length = dim(x)[1]
# i don't use this, but some rows are "low expressing"
thresh = x[,31]=="Yes"

# look at fold change fields
paperboxplot <- function (){
 #to plot the fold change for Ts1.WT_FC for ex
 # x[,3] are the chromsome numbers, x[,25] is Ts1WTvFC
 par(mfrow=c(1,4))
 #Ts1
 boxplot(x[,25]~x[,3], ylim=c(-3,3), xlab="chroms", ylab="fold change",notch=T)
 #Ts13
 boxplot(x[,26]~x[,3], ylim=c(-3,3), xlab="chroms", ylab="fold change",notch=T)
 #Ts16
 boxplot(x[,27]~x[,3], ylim=c(-3,3), xlab="chroms", ylab="fold change",notch=T)
 #Ts19
 boxplot(x[,28]~x[,3], ylim=c(-3,3), xlab="chroms", ylab="fold change",notch=T)
}

# cols 4-21 (18 total) are the expression data for WT and trisomic cell lines
# list the copy number for each chromosome 
copynumber1 = c(rep(2,17),3)
copynumber13 = c(rep(2,6), 3, rep(2,2),3,2,3,2,3,rep(2,4))
copynumber16 = c(2,3,2,3,3,rep(2,13))
copynumber19 = c(rep(2,15),3,rep(2,2))

#which rows below to which chroms
chr1idx = which(x[,3]==1)
chr13idx = which(x[,3]==13)
chr16idx = which(x[,3]==16)
chr19idx = which(x[,3]==19)

# 6columns: probeID,desc,chrom,mu,alpha,pval
## res13 = matrix(rep(0,6*length(chr13idx)), nrow=length(chr13idx),ncol=6)

## for(i in 1:length(chr13idx)){
##   out = lm( t( x[chr13idx[i], 4:21]) ~ log2(copynumber13))
##   mu = coef(summary(out))[1]
##   alpha = coef(summary(out))[2]
##   pval = coef(summary(out))[2,4]
##   res13[i,1] = as.character(x[chr13idx[i],1])
##   res13[i,2] = x[chr13idx[i],2]
##   res13[i,3] = x[chr13idx[i],3]
##   res13[i,4] = mu
##   res13[i,5] = alpha
##   res13[i,6] = pval
## }
## write.table(res13, file="chr13regression.txt", sep="\t", row.names=F, quote=F)


# compute the linear model for each gene and return data frame
computealpha2 <- function(chromrows, chromcopynumber){
  # computealpha(chr13idx, copynumber13)
  # rows=num genes, cols=6 (name, symbol, chrom, mu, alpha, pval)
  N = length(chromrows)
  probes = vector(length=N, mode="character")
  symbols = vector(length=N, mode="character")
  res = matrix(rep(0,4*length(chromrows)), nrow=length(chromrows),ncol=4)
  for(i in 1:length(chromrows)){
    out = lm( t( x[chromrows[i], 4:21]) ~ log2(chromcopynumber))
    mu = coef(summary(out))[1]
    alpha = coef(summary(out))[2]
    pval = coef(summary(out))[2,4]
    
    probes[i] = as.character(x[chromrows[i],1])
    symbols[i] = as.character(x[chromrows[i],2])
    res[i,1] = x[chromrows[i],3]
    res[i,2] = mu
    res[i,3] = alpha
    res[i,4] = pval
  }
  df = data.frame(probes, symbols, res[,1], res[,2], res[,3], res[,4])
  names(df) = c("probes", "symbols", "chrom", "mu", "alpha", "pval")
  return(df)
}


#plotting of graphs: col2=amon, col3=mus t31
# all chroms
amon_mus=read.table("comp_all_new.txt")
plot(amon_mus[,2], amon_mus[,3], xlab="trisomic alpha", ylab="Mouse RH alpha", pch=".", cex=2, main="correlation amon data vs mouse data")
cor.test(amon_mus[,2], amon_mus[,3])
out = lm(amon_mus[,3] ~ amon_mus[,2]) 
abline(out)
summary(out)
#print
dev.print(device=pdf, file="cis_amon_v_mouse_allchrs_new1.pdf")


# chrs 13 and 16
amon_mus = read.table("comp13_16.txt")
plot(amon_mus[,2], amon_mus[,3], xlab="amon", ylab="mouse", main="correlation amon data vs mouse data chrs 13, 16")

#fancy qplot
library(ggplot2)
qplot(V2, V3, data=amon_mus, alpha=I(1/3), geom=c("point", "smooth"), method="lm")


##### HUMAN
setwd("human/")
# no FDR thresh
ah = read.table("comp_amon_H_allcis.txt")
cor.test(ah[,2], ah[,3])
ah.out = lm(ah[,3]~ah[,2])
plot(ahnew[,2],ahnew[,3], xlab="amon mouse", ylab="human rh", main="cis alphas amon data vs human rh")
abline(out)
