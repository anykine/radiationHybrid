#b=read.table("batch1_with_index.txt", header=T)
#r=read.table("hg18_retention1.txt", header=T)

chromes=c("chr01","chr02","chr03","chr04","chr05","chr06","chr07","chr08","chr09",
"chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18",
"chr19","chr20","chr21","chr22","chrX", "chrY")
#cell="c28"
cells=c("c25", "c26", "c27", "c28", "c29", "c30", "c31", "c32")

for (i in 1:8) {
	for (j in 1:24) {

cell=cells[i]
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
}