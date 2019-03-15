#compare the two histograms
comparehists <-function(){

#marker analysis hum-mus
  subset = read.table("mus_hum_zerogene_marker_only_alphas.txt")
  full = read.table("./bymarker/mus_hum_marker_ortholog_alphas.txt")
#plotting the two hists on top
  a = hist(full[,3], col="red", ylim=c(0,40000), xlab="correlation coeff")
  par(new=T)
  hist(subset[,3], col="blue", breaks=a$breaks, ylim=c(0,40000), xlab="")
}

# t-test between gene-ful and zero-gene eqtls
comparedist <- function(){
  geneful = read.table("mus_hum_gene_marker_only_alphas.txt")
  geneless = read.table("mus_hum_zerogene_marker_only_alphas.txt")
  return(t.test(geneful[,3], geneless[,3]))
}
