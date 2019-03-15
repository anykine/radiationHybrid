#make the histogram, hum marker corr mus marker (across all genes)
#alphas
alpha = read.table("mus_hum_marker_ortholog_alphas.txt")
par(mfrow=c(1,2))
hist(alpha[,3], breaks=100, col="red", xlab="Correlation coeff of alphas", main="Distribution of correlation coeffs\n for orthologous markers between mouse and human")

hist(alpha[,4], breaks=100, col="blue", xlab="pvals of correlation coeffs", main="Distribution of pvals for correlation coeffs")

dev.print(device=pdf, file="bigcorr_by_marker.pdf")

#-log pvals can also be plotted
