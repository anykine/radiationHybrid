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
res = matrix('NA', 24, 2)

for (i in 2:25){
#for (i in 2:3){
	idx = data[,1]>	breaks[i-1] & data[,1]<=breaks[i]
	#cat(sum(idx),"\n")
	res[i-1,1] = mean(data[idx,3])
	res[i-1,2] = sd(data[idx,3])/sqrt(length(data[idx,3]))
	#fillmatrix(data[idx,3], i-1,res)
}

#plot
labels = seq(1:24)
bp = barplot(as.numeric(res[,1]), names.arg = labels, ylim=c(0,1.0), xlab="chrom", ylab="mean alpha")
for (i in 1:length(bp)){
	arrows(bp[i], as.numeric(res[i,1])-as.numeric(res[i,2]), bp[i], as.numeric(res[i,1])+as.numeric(res[i,2]), angle=90,code=3,length=0.01)
}
title("mean cis alphas by chromosomes for human")
dev.print(device=pdf, file="cis_alpha_per_chromFDR40.pdf")

