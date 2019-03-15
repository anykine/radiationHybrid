# take expression matrix and average probe replicates to get
# one row per gene
x = read.table("all.expr.genenames.txt", sep="\t")
genenames = unique(x[,1])
res = data.frame()
gene.names = vector(mode="character", length=length(genenames))
res.data = matrix(rep(0,240*length(genenames)), ncol=240)
for (i in 1:length(genenames)){
  idx = which(x[,1]==genenames[i])
  gene.names[i] = as.character(genenames[i])
  res.data[i,] = apply(x[idx, 2:241], 2, mean, na.rm=T)
}
a = data.frame(res.data, row.names=as.character(genenames))
write.table(a, file="all.expr.merged.txt",quote=F, sep="\t", col.names=F)
