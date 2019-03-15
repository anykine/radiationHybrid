# classify the samples as male/female based on X
# chrom data
xdata = read.table("xonly.txt", header=T)
xdata.means = apply(xdata[,5:244], 2, mean, na.rm=T)

# if you wanted to try to estimate means from
# sample means
library(mclust)
#remove NA's
a = Mclust(xdata.means)
a$parameters

#based on 95% CI
#means
#          1           2 
#-0.07745897  0.73453623
#SD's
#$sigmasq
#[1] 0.006762906 0.045580694
hist(xdata.means,breaks=50)
abline(v=a$parameters$mean[1], col="red")
abline(v=a$parameters$mean[2], col="blue")
abline(v=a$parameters$mean[1]+3*sqrt(a$parameters$variance$sigmasq[1]), col="red")
abline(v=a$parameters$mean[2]-3*sqrt(a$parameters$variance$sigmasq[2]), col="blue")
# based on this analysis, use a cutoff 0.169
# male < 0.169
# female > 0.169
female.idx = which(xdata.means>0.169)
#write.table(female.idx, file="fem.idx", sep="\t", quote=F)
