#!/bin/bash
#code to smooth input data
# R batch2sortnew.txt batch2_smoothed.txt --no-save -q < smooth.R

args=commandArgs()
moving.average <- 
function(x, k) { 
	n <- length(x)  
	y <- rep(0, n)   
	for (i in (k/2):(n-5) )  
		y[i] <- mean(x[ ((i-k/2)+1) : (i+(k/2))  ]) 
 	return(y) 
 } 


smooth=read.table(args[2],header=TRUE);
cells=names(smooth)[4:length(names(smooth))];
rownum=dim(smooth)[1];
out=matrix(0,rownum,length(cells));
for (i in 1:length(cells)) {
	print(i)
	out[,i]=moving.average(smooth[cells[i]][,1],10)
}
write.table(out, file=args[3], sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
