# R commands to generate plot of Rvals versus number of mismatches
# and plot of identities by probe position

plotidentity<-function(infile){
	f = read.table(infile, sep=",")
	#f = read.table("results5a2.txt", sep=",")
	f
	plot(f[,1], f[,2]/152, ylim=c(0,1), xlab="probe position",ylab="%identity", main="probe identity by position (N=152)")
}

plotrval <-function(){
	file = read.table("results5a1.txt", sep="\t", header=T)
	plot(file$nummismatches, file$rval, ylim=c(-5,5), xlab="num mismatches", ylab="rval", main="rvalue v # mismatches")
	abline(lm(file$rval ~ file$nummismatches))	
}
#data.y=c()
#data.x=c()
#for (i in min(file[,1]):max(file[,1]) ){
#	tempmean = mean(file[which(file[,1] == i),2])
#	data.y = c(data.y, tempmean)
#	data.x = c(data.x, i)
#	#cat(vec,"\n")
#}
#plotavgR <-function(){
#	plot(data.x, data.y, xlab="number of mismatches", ylab="log Rvalue",main="Mouse-Hamster probe mismatches v Rvalue")
#}
#
#plotalldata <-function(){
#	plot(file[,1], file[,2],xlab="num of mismatches", ylab="log Rvalue", main="Mouse-Hamster probe mismatches v Rvalue")
#}
