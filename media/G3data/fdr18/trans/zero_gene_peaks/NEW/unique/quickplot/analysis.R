# plot some diagnostic plots
# marker 488 regulates several genes, do the peaks all coincide? are they really peaks?
data = read.table("zgmarker488.txt")
chr1 = which(data[,1]==1)
chr1.5 = chr1[1:600]
#par(mfrow=c(4,1))

#one way to plot
zgplot1 <- function() {
 plot(data[chr1.5,2], data[chr1.5, 3], pch=1, type="b")
 #par(new=T)
 plot(data[chr1.5,2], data[chr1.5, 4], pch=2, type="b")
 plot(data[chr1.5,2], data[chr1.5, 5], pch=3, type="b")
 plot(data[chr1.5,2], data[chr1.5, 6], pch=4, type="b")
}


# an overlap plot
zgplot2 <- function(){
 plot(data[chr1.5,2], data[chr1.5, 3], type="b",pch=1, lty=1, xaxt='n', yaxt='n',ylim=c(1,4))
 for (i in 6:8){
   lines(data[chr1.5,2],data[chr1.5,i], type="l", lty=i, col="grey20")
 }
 #pull out 1/20 labels
 idx = seq(1,length(chr1.5), 20)
 axis(1, data[chr1.5[idx], 2], , las=2)
 axis(2, at=seq(1:7), lables = seq(1:7), las=2, tck=1)
}
