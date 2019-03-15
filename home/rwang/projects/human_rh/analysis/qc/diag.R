#plotting chrom 1, expr and presence/absence of marker

#marker data for chrom1
marker = read.table("markerpos1.txt", header=T, sep="\t")
#expression data for chrom1
ex = read.table("exprpos1.txt", header=T, sep="\t")
#plot expression along position
plot(ex$pos_start, ex$c1, pch="*", ylim=c(-1,10), las=2,cex.axis=.1, ylab="ratio of expression in cell line #x", xlab="bp")

for (i in 1:length(marker$g3_hybrid_scores)){
	#split the vector
	#check if cell line 1 is 0 or 1 for this marker
	if ( unlist(strsplit(as.character(marker$g3_hybrid_scores[i]),""))[1]==0 ){
		#print segment of marker that is present
		segments(marker$chromStart[i],0,marker$chromEnd[i],0, col="red", lwd=4)
	}
	cat(i,"\n")
}
