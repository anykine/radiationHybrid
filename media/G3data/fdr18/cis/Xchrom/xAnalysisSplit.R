#plot the data
data = read.table("../cis_FDR40.txt")
geneperchrom=c(
2059, 1354, 1182, 789, 966, 1108, 971,
749, 853, 778, 1352, 1109, 386,
672, 619, 875, 1201, 305, 1401,
688, 292, 480, 784, 23)

#ea num is end of chromN
breaks = c(
0,
2059, 3413, 4595, 5384, 6350, 7458,
8429, 9178, 10031, 10809, 12161, 13270,
13656, 14328, 14947, 15822, 17023, 17328,
18729, 19417, 19709, 20189, 20973, 20996
)

fillmatrix <- function(data, mrow,res){
	cat(mean(data),"\n");
	res[mrow,1] = mean(data)
	res[mrow,2] = sd(data)/sqrt(length(data))
}

#prealloc: chrom, stderr
#res = matrix('NA', 24, 4)
res = data.frame("meanall"=rep(0,24), "sdall"=rep(0,24), "meannegs"=rep(0,24), "sdnegs"=rep(0,24), "meanpos"=rep(0,24), "sdpos" = rep(0,24))
for (i in 2:25){
#for (i in 2:3){
	idx = which(data[,1]>breaks[i-1] & data[,1]<=breaks[i])
	#cat(sum(idx),"\n")
	res[i-1,1] = mean(data[idx,3])
	res[i-1,2] = sd(data[idx,3])/sqrt(length(data[idx,3]))
        negs = which(data[idx,3]<0)
        pos  = which(data[idx,3]>0)
        negs1 = idx[negs]
        pos1 = idx[pos]
        res[i-1,3] = mean(abs(data[negs1,3]))
        res[i-1,4] = sd(abs(data[negs1,3]))/sqrt(length(data[negs1,3]))
        res[i-1,5] = mean(data[pos1,3])
        res[i-1,6] = sd(abs(data[pos1,3]))/sqrt(length(data[pos1,3]))
}

#plot
par(mfrow=c(2,1))
labels = seq(1:24)
bp = barplot(as.numeric(res[,3]), names.arg = labels, ylim=c(0,1.0), xlab="chrom", ylab="mean alpha")
for (i in 1:length(bp)){
	arrows(bp[i], as.numeric(res[i,3])-as.numeric(res[i,4]), bp[i], as.numeric(res[i,3])+as.numeric(res[i,4]), angle=90,code=3,length=0.01)
}
title("mean cis negalphas by chromosomes for human")
bp = barplot(as.numeric(res[,5]), names.arg = labels, ylim=c(0,1.0), xlab="chrom", ylab="mean alpha")
for (i in 1:length(bp)){
	arrows(bp[i], as.numeric(res[i,5])-as.numeric(res[i,6]), bp[i], as.numeric(res[i,5])+as.numeric(res[i,6]), angle=90,code=3,length=0.01)
}
title("mean cis posalphas by chromosomes for human")
#dev.print(device=pdf, file="cis_alpha_per_chromFDR40.pdf")

#a t-test between pos alpha chrom 23 and chrom 13
chr13pos = which(data[,1] > 13269 & data[,1] < 13656 & data[,3]>0)
chr23pos = which(data[,1] > 20188 & data[,1] < 20973 & data[,3]>0)
t.test(data[chr13pos,3], data[chr23pos,3])
chr18pos = which(data[,1] > 17022 & data[,1] < 17329 & data[,3]>0)
t.results = c()
for (i in 1:24){
  chrpos = which(data[,1] > breaks[i] & data[,1] < breaks[i+1] & data[,3]>0)
  t.results = c(t.results, t.test(data[chr23pos,3], data[chrpos,3])$p.value)
}
# only chroms 13 and 24 are different from chrom23
