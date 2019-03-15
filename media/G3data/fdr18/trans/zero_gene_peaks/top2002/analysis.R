# do a correlation of the genes regulated by the "same" 
#  0-gene eqtls

total = 2001
data = matrix(0, total+1, 4);
for (n in 0:total) {
	fname = paste("data", n, ".txt", sep="");
	#cat(fname);
	x = read.table(fname)
	x.alpha = cor.test(x[,1], x[,3], method="pearson")
	#x.alpha1 = cor.test(x[,1], x[,3], method="spearman")
	x.nlp = cor.test(x[,2], x[,4], method="pearson")
	#x.nlp1 = cor.test(x[,2], x[,4], method="spearman")
	data[n+1, 1] = x.alpha$p.value
	data[n+1, 2] = x.alpha$estimate
	#data[n+1, 2] = x.alpha1$p.value
	data[n+1, 3] = x.nlp$p.value
	data[n+1, 4] = x.nlp$estimate
	#data[n+1, 4] = x.nlp1$p.value
	#dat = paste(x.alpha$p.value, x.alpha1$p.value, x.nlp$p.value, x.nlp1$p.value, sep="\t")
	#cat(dat);
}

outfile = paste("correlations", total, ".txt", sep="")
write.table(data, file=outfile, sep="\t", quote=F, row.names=F, col.names=F)

