#poisson 

counts = read.table("markers_regulating_genes_transFDR40.txt")
length = dim(counts)[1]
#my est mean
mu = mean(counts[,3])

calc_pois <- function(x){
	#this gives a vector of answers for p(X=x1), p(X=x2)...
	vec = seq(0, x-1, 1)
	ans = dpois(vec, mu, log=T)
	return (1-sum(exp(ans)))
}