# mouse
#plot the data
data = read.table("../comp_MH_cis_alphas/mouse_cis_peaks_FDR40.txt")

geneperchrom = c(
1205,  1773,  950,  1178,  1196,
1136,  1631,  971,  1192,  933,
1582,  690,  730,  707,  771,
670,  923,  503,  703,  687, 
14)

#ea num is end of chromN, 0 added at beg
breaks = c(
0, 1205,
2978, 3928, 5106, 6302, 7438,
9069, 10040, 11232, 12165, 13747,
14437, 15167, 15874, 16645, 17315,
18238, 18741, 19444, 20131, 20145
)

#prealloc: chrom, stderr
res = matrix('NA', 21, 2)

for (i in 2:22){
#for (i in 2:3){
	idx = data[,1]>	breaks[i-1] & data[,1]<=breaks[i]
	#cat(sum(idx),"\n")
	res[i-1,1] = mean(data[idx,3])
	res[i-1,2] = sd(data[idx,3])/sqrt(length(data[idx,3]))
	#fillmatrix(data[idx,3], i-1,res)
}

#plot
labels = seq(1:21)
bp = barplot(as.numeric(res[,1]), names.arg = labels, ylim=c(0,1.0), xlab="chrom", ylab="mean alpha")
for (i in 1:length(bp)){
	arrows(bp[i], as.numeric(res[i,1])-as.numeric(res[i,2]), bp[i], as.numeric(res[i,1])+as.numeric(res[i,2]), angle=90,code=3,length=0.01)
}
title("mean cis alphas by chromosomes for mouse")
dev.print(device=pdf, file="mouse_cis_alpha_per_chromFDR40.pdf")

