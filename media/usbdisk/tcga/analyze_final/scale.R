# 7/7/10 - Hapmap data
# 1. mean center autosomes
# 2. center X at log(2/1) and log(2/2) using mclust
#
tab5rows = read.table("all.cghtcga.scaled_smoothed", header=T, nrows=5)
classes = sapply(tab5rows, class)
cgha = read.table("/media/usbdisk/tcga/analyze_final/allcgh1.txt", header=T, colClasses=classes, nrows=227606)
#cgha = read.table("/media/usbdisk/tcga/analyze_final/allcgh1.txt", header=T)

####### SCALE all chroms #########

idx = list()
oldmean = vector(mode="numeric", length=22)
newmean = vector(mode="numeric", length=22)
# mean center each chromosome, Xchrom already taken care of, skip Ychrom
for (i in 1:22){
  idx[[i]] = which(cgha[,2] == i)
  oldmean[i] = mean(unlist(cgha[idx[[i]], 5:241]))
  cgha[idx[[i]], 5:241] = cgha[idx[[i]],5:241]-oldmean[i]
  newmean[i] = mean(unlist(cgha[idx[[i]], 5:241]))
}

#distrib of autosomes
#auto = which(cgha[,2]<23)
#hist(unlist(cgha[auto,5:241]), breaks=200) #takes a long time

#find means of Xchrom
library(mclust)
idx23 = which(cgha[,2]==23)
#need to convert dataframe to a matrix
tmp = as.vector(as.matrix(cgha[idx23,5:241]))
a = Mclust(tmp, G=2)
#hist(unlist(cgha[idx23,5:241]), breaks=400, xlim=c(-1,1))


#scale the Xchrom so second mode is at log2(2/1)
newx = cgha[idx23, 5:241]
newx.1 = newx - a$parameters$mean[1]
newx.1.g = Mclust(unlist(newx.1), G=2)
#after mean centering, it looks right
cgha[idx23,5:241] = newx.1
write.table(cgha, file="all.cghtcga.scaled1", quote=F, row.names=F, sep="\t")

#this scaling shifts it too far
newx.2 = newx.1 * 1/newx.1.g$parameters$mean[2]
hist(unlist(newx.2), breaks=400, xlim=c(-1,1))

cghnew[idx23, 5:241] = newx.2


#chrY scale so that males are centered at zero
#idx24 = which(cgha[,2]==24)
#a = Mclust(unlist(cgha[idx24,5:223]), G=2)
#tmp = cgha[idx24,5:223]
#tmp = tmp - a$parameter$mean[2]
#cgha[idx24,5:223] = tmp


# side by side scaled v scaled-smoothed
par(mfrow=c(2,1))
plot(cgha[idx[[i]],3], cgha[idx[[i]],5], pch=".", cex=3, ylim=c(-1,1))
plot(sm[idx[[i]],3], sm[idx[[i]],5], pch=".", cex=3, ylim=c(-1,1))
abline(h=.6, lty=3)
abline(h=-.6, lty=3)


#need to mean center each chrom/ each sample
par(mfrow=c(2,1))
plot(   cgha[idx[[i]],3],      cgha[idx[[i]],5], pch=".", cex=3, ylim=c(-1,1))
plot(cghraw[idx[[i]],3], cghraw[idx[[i]],5], pch=".", cex=3, ylim=c(-1,1))
cgh.c = cghraw[idx[[i]],5] - mean(cghraw[idx[[i]],5])
x11()
plot(cghraw[idx[[i]],3], cgh.c, pch=".", cex=3, ylim=c(-1,1))

#does each chrom vary by same amount? maybe center by sample?
ms = matrix(rep(0,5688), nrow=24)
for (samp in 1:237){
  for (chr in 1:22){
    ms[chr,samp] = mean(cghraw[idx[[chr]], samp+4])
  }
}
med = matrix(rep(0,100), 10,10)
for (samp in 1:10){
  for (chr in 1:10){
    med[chr,samp] = median(cghraw[idx[[chr]], samp+4])
  }
}

par(mfrow=c(2,1))
plot(cghraw[idx[[7]],3], cghraw[idx[[7]],10], pch=".", cex=3,ylim=c(-1,1))
plot(cghraw[idx[[7]],3], cghraw[idx[[7]],12], pch=".", cex=3,ylim=c(-1,1))

hist(cghraw[idx[[7]],10], breaks=100, xlim=c(-2,2));
hist(cghraw[idx[[7]],12],breaks=100, xlim=c(-2,2))

x11(); hist( unlist(ms), breaks=100)
x11(); plot(cghraw[idx[[10]],3], cghraw[idx[[10]],13], pch=".", cex=3)

par(mfrow=c(3,2))
for(jj in 19:24){
  hist(ms[jj,], main=paste("chr",jj))
}
hist(ms[1,])

###############
# smoothed data
cgh.sm = read.table("allcgh1.txt_smoothed", header=T, colClasses=classes, nrows=227606)

mss = matrix(rep(0,5688), nrow=24)
for (samp in 1:237){
  for (chr in 1:22){
    mss[chr,samp] = mean(cgh.sm[idx[[chr]], samp+4])
  }
}
idx = list()
oldmean = vector(mode="numeric", length=22)
newmean = vector(mode="numeric", length=22)
# mean center each chromosome, Xchrom already taken care of, skip Ychrom
for (i in 1:22){
  idx[[i]] = which(cgh.sm[,2] == i)
  oldmean[i] = mean(unlist(cgh.sm[idx[[i]], 5:241], use.names=F))
  cgh.sm[idx[[i]], 5:241] = cgh.sm[idx[[i]],5:241]-oldmean[i]
  newmean[i] = mean(unlist(cgh.sm[idx[[i]], 5:241], use.names=F))
}


#find means of Xchrom
library(mclust)
idx23 = which(cgh.sm[,2]==23)
a = Mclust(unlist(cgh.sm[idx23,5:241], use.names=F), G=2)

#scale the Xchrom so second mode is at log2(2/1)
newx = cgh.sm[idx23, 5:241]
newx.1 = newx - a$parameters$mean[1]
newx.1.g = Mclust(unlist(newx.1), G=2)
newx.2 = newx.1 * 1/newx.1.g$parameters$mean[2]
#after mean centering, it looks right
cgh.sm[idx23,5:241] = newx.2
write.table(cgh.sm, file="allcgh1.txt_smoothed.scaled", quote=F, row.names=F, sep="\t")




par(mfrow=c(2,1))
plot(cghraw[idx[[7]],3], cghraw[idx[[7]],5], pch=".", cex=3,ylim=c(-1,1))
plot(cgh.sm[idx[[7]],3], cgh.sm[idx[[7]],5], pch=".", cex=3,ylim=c(-1,1))
x11()
par(mfrow=c(2,1))
plot(cghraw[idx[[7]],3], cghraw[idx[[7]],116], pch=".", cex=3,ylim=c(-1,1))
plot(cgh.sm[idx[[7]],3], cgh.sm[idx[[7]],116], pch=".", cex=3,ylim=c(-1,1))

plot(cghraw[idx[[7]],3], cghraw[idx[[7]],10], pch=".", cex=3,ylim=c(-1,1))
plot(cgh.sm[idx[[7]],3], cgh.sm[idx[[7]],10], pch=".", cex=3,ylim=c(-1,1))

plot(cghraw[idx[[7]],3], cghraw[idx[[7]],12], pch=".", cex=3,ylim=c(-1,1))
plot(cgh.sm[idx[[7]],3], cgh.sm[idx[[7]],12], pch=".", cex=3,ylim=c(-1,1))

plot(cghraw[idx[[4]],3], cghraw[idx[[4]],12], pch=".", cex=3,ylim=c(-1,1))
plot(cgh.sm[idx[[4]],3], cgh.sm[idx[[4]],12], pch=".", cex=3,ylim=c(-1,1))
