#loop
library("mclust")
sink("mclust.output")
x = read.table("g3matrix_pos_sorted_nodup_smoothed")
for (i in 1:80)
	a = Mclust(x[,i], G=c(2,3))
	cat("number", i, "\n");
	cat(a$parameters, "\n")
	cat(a$BIC,"\n")
	cat(a$bic,"\n")
	
