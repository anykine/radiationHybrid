#plot big correlation by gene (mouse v human)
#alphas

alphas = read.table("hum_mus_gene_ortholog_comp.txt")
par(mfrow=c(1,2))
hist(alphas[,1], breaks=100, col="red", xlab="Correlation coeffs of alphas", main="Distribution of correlatioin coeffs\n by gene between mouse and human")
hist(alphas[,2], breaks=100, col="blue", xlab="pvals of correlation coeffs", main="Distribution of pvals")
dev.print(device=pdf, file="bigcorr_by_gene.pdf")
