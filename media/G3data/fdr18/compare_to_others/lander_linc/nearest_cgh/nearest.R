#nearest linc or wold noncoding trans ceQTL

transzg = read.table("/media/G3data/fdr18/trans/zero_gene_peaks/NEW/peaks3/zero_gene_peaks3_ucschg18_FDR40.txt")
transzg30 = read.table("/media/G3data/fdr18/trans/zero_gene_peaks/NEW/peaks3/zero_gene_peaks3_ucschg18_FDR30.txt")
muszg = read.table("/media/G3data/fdr18/trans/zero_gene_peaks/mouse/0_gene_300k_trans_4.0_peak2.txt")

hist(transzg30[,4], xlim=c(4,8), ylim=c(0,2500), breaks=20)
#nearest trans
nearest = read.table("pval_closest_cgh_tolinc.txt")
#abline(v=nearest[,5])

hist(transzg30[,4], xlim=c(4,8), ylim=c(0,2500), breaks=20, xlab="-log10 P")
points(nearest[1:6,5], rep(0,6), pch=24, col="red", bg="red")
dev.print(device=pdf, file="closest_lincRNA_to_zerogene_FDR30.pdf")
