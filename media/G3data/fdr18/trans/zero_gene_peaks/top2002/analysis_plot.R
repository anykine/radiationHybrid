# plot the correlations data

cordata = read.table("correlations2001.txt")
#jpeg(filename="cor615.jpg", width=800, height=400)
pdf(file="cor2001.pdf" )
par(mfrow=c(2,2))
#alpha pearson
hist(cordata[,1], breaks=100, main="distrib of pvals for alphas")
hist(cordata[,2], breaks=100, main="distrib of alphas")
#alpha spearman
#hist(cordata[,2], breaks=100)
#nlp pearson
hist(cordata[,3], breaks=100, main="distrib of pvals for nlp")
hist(cordata[,4], breaks=100, main="distrib of nlps")
#nlp spearman
#hist(cordata[,4], breaks=100)
dev.off()
