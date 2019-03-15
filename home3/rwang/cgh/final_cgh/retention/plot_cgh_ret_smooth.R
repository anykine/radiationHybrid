#create plots of retention frequency for each chrom
#smoothed by a window of 10(or 5 or 8)  markers

#helpful for debugging
#options(error=recover)
rf=read.table("g3retention_freq.txt",header=F)
chromnum = c(seq(1,22), "X", "Y")
chroms = paste(c(rep("chr0",9),rep("chr",15)), chromnum, sep="")
#centromere = read.table("../plots/test/hg18centromere.txt", header=T)
centromere = read.table("centromere/hg18centromere_gap1.txt", header=T)
#chromes=list("chr01", "chr02", "chr03", "chr04", "chr05", "chr06", "chr07", "chr08", "chr09", "chr10", "chr11", "chr12", "chr13", "chr14", "chr15", "chr16", "chr17", "chr18", "chr19", "chrX", "chrY") 

title_c="CGH_Retention_"
#current=getwd()
#dir.create(title_c)
#setwd(title_c)

moving.average <- function(x,k){
	n<-length(x)
	y<-rep(0,n)
	for (i in (k/2):(n-5))
		y[i] <- mean(x[ ((i-k/2)+1) : (i+(k/2)) ])
	return(y)
}

for (i in 1:length(chroms)) {
	# title of graph 
	title=paste(title_c, chroms[i],"_cent",sep="");
	fname=paste(title, ".jpg", sep="")
 	jpeg(filename=fname, width = 800, height = 600) 
	idx = rf[,2]==chroms[i]
	#plot(rf[idx,3]/1000000,rf[idx,5], pch=".", cex=.8, main=title, xlab="chromosome pos (MB)", ylab="RF", ylim=c(0,1))
	plot(rf[idx,3]/1000000,moving.average(rf[rf[,2]==chroms[i],5],10), pch=".", cex=.8, main=title, xlab="chromosome pos (MB)", ylab="RF", ylim=c(0,1))
	if (i==17){
		abline(v=73.68)
		abline(v=7.51)
	}

	#add in centromere
	abline(v=centromere$chromStart[centromere$chrom == chroms[i]]/1000000 )
	abline(v=centromere$chromEnd[centromere$chrom == chroms[i]]/1000000 )
	#segments(centromere$chromStart[centromere$chrom == chroms[i]]/1000000, 0, centromere$chromEnd[centromere$chrom == chroms[i]]/1000000, 0, lwd=5, col="grey50")
#	if (chroms[i] == "chrX" | chroms[i] =="chrY"){
#		abline(h=0.1132,lty=3)
#	} else{
#		abline(h = 0.0554,lty=3)
#	}
	dev.off()
}
#setwd(current)
#dev.off()
