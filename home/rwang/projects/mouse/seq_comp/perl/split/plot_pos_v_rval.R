#For those seqs that have a mismatch at pos i, get avg Rvalue for those 
# seqs and plot.
# RW 8/23/07
# pos_v_rval.txt format: 
#pos avgRval_mismatch, avgRval_mismatchSE, num_seqmismatch, avgRval_match,avgRval_matchSE,num_seqmatch

#for mismatches
plotPosRvalMM<-function() {
	data = read.table("pos_v_rval2.txt", header=T, sep="\t")
	# this plots rval for mismatches
	plot(seq(1,60), data[,2], ylim=c(-1.2,1.2), xlab="position", ylab="Rvalue",main="Rvalue v Mismatch Position for Mouse-Hamster")
	#this plots error bars w/ +/- standard error
	#arrows(seq(1,60),data[,2]-data[,3], seq(1,60),data[,2]+data[,3],angle=90,code=3,length=0.01)
	#to write PDF
	#dev.print(dev=pdf,file="pos_v_rvalmismatch.pdf")
}

#for matches
plotPosRvalM<-function() {
	data = read.table("pos_v_rval2.txt", header=T, sep="\t")
	# this plots rval for mismatches
	plot(seq(1,60), data[,5], ylim=c(-1.2,1.2), xlab="position", ylab="Rvalue",main="Rvalue v Match Position for Mouse-Hamster")
	#this plots error bars
	#arrows(seq(1,60),data[,5]-data[,6], seq(1,60),data[,5]+data[,6],angle=90,code=3,length=0.01)
	#dev.print(dev=pdf,file="pos_v_rvalmatch.pdf")
}

