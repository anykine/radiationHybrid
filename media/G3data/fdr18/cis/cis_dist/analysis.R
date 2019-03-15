# plot the distance between cis gene and its peak marker
cis = read.table("dist_cis_gene.txt")
diff = abs(cis[,2] - cis[,4])
#hist(diff, breaks=100, main="cis: distance gene to marker", xlab="dist (bp)", col="red")
hist(diff/1e6, breaks=100, main="cis: distance gene to marker", xlab="dist (Mb)", col="red", las=1)
dev.print(device=pdf, file="dist_cis_gene.pdf")
