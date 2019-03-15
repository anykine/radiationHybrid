#library(made4)
#x = read.table("all.expr.txt")
#heatplot(x[,1:40])


############################
# distrib of chrX for all/male/female
# across of mult GBM samples
###########################
d = read.table("xonly")

data = d[,5:244]
fem.idx = read.table("fem.idx")
f.cols = c(fem.idx[,2])

br=seq(-11,7,by=0.004)
#allexpr
h.all = hist(c(as.matrix(data)), breaks=br,xlim=c(-2,2))
#plot females only
h.fem = hist(as.matrix(data[,f.cols]), breaks=br, xlim=c(-2,2))
# males only
h.mal = hist(as.matrix(data[,-f.cols]), breaks=br, xlim=c(-2,2))

#overlay allexpr, males and females
plot(h.all, xlim=c(-2,2), ylim=c(0,12500), main="expression of Xchrom genes")
plot(h.mal, xlim=c(-2,2), ylim=c(0,12500), add=TRUE, col="blue")
plot(h.fem, xlim=c(-2,2), ylim=c(0,12500), add=TRUE, col="pink")

# plot histograms separately
x11();par(mfrow=c(3,1))
plot(h.all, xlim=c(-2,2), ylim=c(0,12500))
plot(h.mal, xlim=c(-2,2), ylim=c(0,12500), col="blue")
plot(h.fem, xlim=c(-2,2), ylim=c(0,12500), col="pink")

# make a heatmap by sex
data.matrix = as.matrix(data)
data.matrix[is.na(data.matrix)] = 0
data.dist = cor(data.matrix)
sex.label = rep("M", 240)
sex.label[f.cols] = "F"
#pdf(file="heat_sex.pdf")
heatmap(data.dist, Rowv=NA, Colv=NA, labRow=sex.label, labCol=sex.label, cex.lab=0.15)
#dev.off()
hier1=hclust(as.dist(1-data.dist), method="average", labels=sex.label)
