#fdr thresh this data
#use this code to calc FDR
source("~/lib/R/fdr.R")
d = read.table("regress_results1.txt")
#last column is -log10 of pvalue, convert to p
pvals = 10^(-d[,6])
q = c(0.4, 0.3, 0.2, 0.1, 0.05, 0.01)
thresh = c(0)
for (i in 1:length(q)){
  signif = fdr(pvals, qlevel=q[i], method="original", adjustment.method=NULL, adjustment.args=NULL)
  # get the corresp pval for qlevel
  thresh[i] = max(sort(pvals[signif]))
}
res = cbind(q,thresh)
write.table(res, file="qval_cutoff.txt", sep="\t", quote=F, row.names=F)

# -----------------------------------------
# calculate the number of neg cis alphas for TCGA
#-----------------------------------------
# load all data
cutoffs = read.table("qval_cutoff.txt", header=T)
allcis = read.table("autosomes/cis_with_pos_nothresh.txt")
malecis = read.table("autosomes/male_cis_with_pos.txt")
femalecis = read.table("autosomes/female_cis_with_pos.txt")
name.hdr = c("chrom", "start", "stop", "symbol", "index", "marker", "mu", "alpha", "nlp")

alldata = list(all=allcis, f=femalecis, m=malecis)
#lapply(alldata, FUN=function(a) names(a)=name.hdr)
for (i in 1:length(alldata)){
  names(alldata[[i]]) = name.hdr
  #names(i) = name.hdr
}

# calc number of negative cis eqtlsoh phone
countNegCis = function(data, cutoff){
  cutoff.nlp = -log10(cutoff)
 return(sum(data$alpha < 0 & data$nlp > cutoff.nlp))
 # return(sum(data$alpha >0 & data$nlp > cutoff.nlp))
}

#store the results in a matrix
numNegCis = data.frame()
for (j in 1:length(alldata)){
  for (i in 1:5){
    numNegCis[j,i]=countNegCis(alldata[[j]], cutoffs[i,2])
  }
}

# ---------------------------
# calc the number of neg cis alphas for human RH
# ----------------------------
rh.cutoffs = read.table("/media/G3data/fdr18/cis/hum18_cis_breakpoints.txt", header=T)
rh.cis40 = read.table("/media/G3data/fdr18/cis/cis_FDR40.txt")
rh.numNegCis = data.frame()
text = vector()
names(rh.cis40) = c("gene", "marker", "alpha", "nlp")
for (i in 2:8){
  rh.numNegCis[i,i]=countNegCis(rh.cis40, rh.cutoffs[i,1])
}
text = rh.cutoffs$fdr
rownames(rh.numNegCis) = text
