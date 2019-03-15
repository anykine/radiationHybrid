#older version of plotting of CGH data from josh tutorial 8/9/07
# does not give gain/loss data, prints JPGS
b=read.table("batch2_smoothed.txt", header=T)
r=read.table("hg18_retention_v2.txt", header=T)

chromes=c("chr01","chr02","chr03","chr04","chr05","chr06","chr07","chr08","chr09",
"chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18",
"chr19","chr20","chr21","chr22","chrX", "chrY")

curdir=getwd()

cells=names(b)[4:length(names(b))]
arraynum=length(cells)

for (i in 1:arraynum) {

	cell=cells[i]
	dir.create(cell)
	setwd(cell)

	for (j in 1:24) {
	chr=chromes[j]

	title=paste(cell, "_", chr,".jpeg", sep="")

	jpeg(file=title, width=1024, height=768)
	
	plot( b$start[b$chr==chr], b[,cell][b$chr==chr] ,pch=".",ylim=c(-1,1.5), main=title) 

	if (length(r$start[r$chr==chr & r[cell]==1])>0) {
		segments(r$start[r$chr==chr & r[cell]==1], rep(-.5, length(r$start[r$chr==chr & r[cell]==1])),
		r$stop[r$chr==chr & r[cell]==1],rep(-.45, length(r$stop[r$chr==chr & r[cell]==1])) )
	}

	if (length(r$start[r$chr==chr & r[cell]==0])>0) {
		segments(r$start[r$chr==chr & r[cell]==0], rep(-.6, length(r$start[r$chr==chr & r[cell]==0])),
		r$stop[r$chr==chr & r[cell]==0],rep(-.6, length(r$stop[r$chr==chr & r[cell]==0])) )
	}

	dev.off()
	}
	setwd(curdir)
}
