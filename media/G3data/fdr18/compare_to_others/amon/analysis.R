x = read.csv("/media/G3data/fdr18/compare_to_others/amon/1160058TableS1.csv")
# look at fold change fields
length = dim(x)[1]

thresh = x[,31]=="Yes"

paperboxplot <- function (){
 #to plot the fold change for Ts1.WT_FC for ex
 # x[,3] are the chromsome numbers, x[,25] is Ts1WTvFC
 #Ts1
 boxplot(x[,25]~x[,3], ylim=c(-3,3), xlab="chroms", ylab="fold change",notch=T)
 #Ts13
 boxplot(x[,26]~x[,3], ylim=c(-3,3), xlab="chroms", ylab="fold change",notch=T)
 #Ts16
 boxplot(x[,27]~x[,3], ylim=c(-3,3), xlab="chroms", ylab="fold change",notch=T)
 #Ts19
 boxplot(x[,28]~x[,3], ylim=c(-3,3), xlab="chroms", ylab="fold change",notch=T)
}

#regression chrom1, only interested in cols 4-21 (18 total)
#list the copy number for each chromosome
copynumber1 = c(3, rep(2,17))
copynumber13 = c(rep(2,6), 3, rep(2,2),3,2,3,2,3,rep(2,4))
copynumber16 = c(2,3,2,3,3,rep(2,13))
copynumber19 = c(rep(2,15),3,rep(2,2))

#which rows below to which chroms
chr1idx = which(x[,3]==1)
chr13idx = which(x[,3]==13)
chr16idx = which(x[,3]==16)
chr19idx = which(x[,3]==19)

# 6columns: probeID,desc,chrom,mu,alpha,pval
res13 = matrix(rep(0,6*length(chr13idx)), nrow=length(chr13idx),ncol=6)

for(i in 1:length(chr13idx)){
  out = lm( t( x[chr13idx[i], 4:21]) ~ log2(copynumber13))
  mu = coef(summary(out))[1]
  alpha = coef(summary(out))[2]
  pval = coef(summary(out))[2,4]
  res13[i,1] = as.character(x[chr13idx[i],1])
  res13[i,2] = x[chr13idx[i],2]
  res13[i,3] = x[chr13idx[i],3]
  res13[i,4] = mu
  res13[i,5] = alpha
  res13[i,6] = pval
}
write.table(res13, file="chr13regression.txt", sep="\t", row.names=F, quote=F)

computealpha <- function(chromrows, chromcopynumber){
  # computealpha(chr13idx, copynumber13)
  # rows=num genes, cols=6 (name, symbol, chrom, mu, alpha, pval)
  res = matrix(rep(0,6*length(chromrows)), nrow=length(chromrows),ncol=6)
  for(i in 1:length(chromrows)){
    out = lm( t( x[chromrows[i], 4:21]) ~ log2(chromcopynumber))
    mu = coef(summary(out))[1]
    alpha = coef(summary(out))[2]
    pval = coef(summary(out))[2,4]
    res[i,1] = as.character(x[chromrows[i],1])
    res[i,2] = as.character(x[chromrows[i],2])
    res[i,3] = x[chromrows[i],3]
    res[i,4] = mu
    res[i,5] = alpha
    res[i,6] = pval
  }
  return(res)
}


#plotting of graphs: col2=amon, col3=mus t31
# all chroms
amon_mus=read.table("compall.txt")
plot(amon_mus[,2], amon_mus[,3], xlab="amon", ylab="mouse", main="correlation amon data vs mouse data")
cor.test(amon_mus[,2], amon_mus[,3])
out = lm(amon_mus[,3] ~ amon_mus[,2]) 
abline(out)
summary(out)

# chrs 13 and 16
amon_mus = read.table("comp13_16.txt")
plot(amon_mus[,2], amon_mus[,3], xlab="amon", ylab="mouse", main="correlation amon data vs mouse data chrs 13, 16")
