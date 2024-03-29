#plot alphas for cis and trans
trans40 = read.table("./trans/trans_peaks_FDR40.txt")
cis40 = read.table("./cis/cis_FDR40.txt")
trans30 = read.table("./trans/trans_peaks_FDR30.txt")
cis30 = read.table("./cis/cis_FDR30.txt")
trans20 = read.table("./trans/trans_peaks_FDR20.txt")
cis20 = read.table("./cis/cis_FDR20.txt")
l= matrix(c(1,2), 2,1)
layout(l)
pdf(file="cis_trans_alphas_FDR20.pdf")
hist(trans20[,3], breaks=250, col="red",xlim=c(-5,5),main="trans alphas")
hist(cis20[,3], breaks=250, col="blue",xlim=c(-5,5),main="cis alphas")
dev.off()
