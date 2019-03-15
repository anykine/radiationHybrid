# let's look at cis alphas for mouse
# on X and Y versus all other comromse

#analysis of Xchrom versus autosomes
cis40 = read.table("../comp_MH_cis_alphas/mouse_cis_peaks_FDR40.txt")
cis40.x = cis40[cis40[,1] >= 19445 & cis40[,1]<=20131,]
cis40.auto = cis40[cis40[,1]>=0 & cis40[,1]<19445,]
cis40.xmean = mean(cis40.x[,3])
cis40.automean = mean(cis40.auto[,3])
#do Welch's t-test
t.test(cis40.x[,3], cis40.auto[,3], var.equal=F)
t.test(cis40.auto[,3], cis40.x[,3], var.equal=F)

#look at numbers of cis eQTLs per gene
stringent.x = cis40[ cis40[,4]>4.08 & cis40[,1]>=20190 & cis40[,1]<=20973, ]
stringent.auto = cis40[ cis40[,4]>4.08 & cis40[,1]<20190,]

#number of genes per chrom
