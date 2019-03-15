#Create the cis alpha plot
x = read.table("cis_FDR40.txt")
br = seq(-3.25, 10, 0.05)
hist(x[,3], breaks=br, col="red", xlim=c(-3, 5), main="human cis alphas FDR40", ylab="Counts", xlab="alpha")
dev.print(device=pdf, file="cis_alphas_fdr40_20090917.pdf")
