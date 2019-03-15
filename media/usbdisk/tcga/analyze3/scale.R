#scale the median normalized CGH data
# so that chrX is centered at log(1) and log(2/1)
# plus, flip the sign so its in the same direction as
# TCGA lowess normalized data
cgha = read.table("/media/usbdisk/tcga/cgh/level1/cghcall/all.cghcall.log2ratios.pos.txt", header=T)
idx23 = which(cgha[,2]==23)

left = cgha[,1:4]
right = cgha[ ,5:223]
right = right * -1
cgha = cbind(left, right)

#find means of Xchrom
library(mclust)
#need to convert dataframe to a matrix
tmp = as.vector(as.matrix(cgha[idx23,5:223]))
#a = Mclust(cgha[idx23,5:223], G=2)
a = Mclust(tmp, G=2)
hist(unlist(cgha[idx23,5:223]), breaks=400, xlim=c(-1,1))

# 2nd mean is 0.27

#compare females with whole group
fem = read.table("fem.idx")
fem1 = fem[,2]
new = cgha[idx23, fem1]
hist(tmp, breaks=400, xlim=c(-1,1), ylim=c(0,1e5), freq=T)
par(new=T)
hist(unlist(new), breaks=400, xlim=c(-1,1), ylim=c(0,1e5),col="red", freq=T)
par(new=T)
hist(unlist(not), breaks=400, xlim=c(-1,1), ylim=c(0,1e5),col="blue", freq=T)

#scale the Xchrom so second mode is at log2(2/1)
newx = cgha[idx23, 5:223]
newx.1 = newx.1 - a$parameters$mean[1]
newx.1 = newx * 1/a$parameteres$mean[2]

cghnew = cgha
cghnew[idx23,5:223] = newx.1

write.table(cghnew, file="all.cghcall.scaled.txt", quote=F, row.names=F, sep="\t")


####### SCALE all chroms #########
cgha = read.table("all.cghcall.scaled.txt", header=T)
library(mclust)
idx = list()
# mean center each chromosome
for (i in 1:22){
  idx[[i]] = which(cgha[,2] == i)
  m = mean(unlist(cgha[idx[[i]],5:223]))
  tmp = cgha[idx[[i]],5:223]-m
  tmp = tmp * 1/0.27
  cgha[idx[[i]], 5:223] = tmp
  #a = Mclust(unlist(cgha[idx[[i]], 5:223]), G=2)
}
#chrX already scaled

#chrY scale so that males are centered at zero
idx24 = which(cgha[,2]==24)
a = Mclust(unlist(cgha[idx24,5:223]), G=2)
tmp = cgha[idx24,5:223]
tmp = tmp - a$parameter$mean[2]
cgha[idx24,5:223] = tmp

write.table(cgha, file="all.cghcall.allscaled.txt", quote=F, row.names=F, sep="\t")

