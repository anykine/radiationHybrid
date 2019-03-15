# for each gene, how many peaks regulated it

hm = read.table("HM_genes_regulated_count.txt")

#create the graph
plot(hm[,2], hm[,4], pch=".", cex=3, xlab="Human peaks/gene", ylab="Mouse peaks/gene", main="Hum v. Mus peaks regulating each gene")

reg = lm(hm[,4]~hm[,2])
abline(reg)

dev.print(device=pdf, file="HM_peaks_regulated_each_gene.pdf")

#pick out those highly conserved between the two
mostconserved = identify(hm[,2], hm[,4])
