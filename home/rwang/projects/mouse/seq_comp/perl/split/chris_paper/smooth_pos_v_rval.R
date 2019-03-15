# RW 9/24/07
# smooth the Rvalue of mismatches over a window & get SE's


#start=start index
#window size of smoothing (window=5 means 1,2,3,4,5 or 2,3,4,5,6...)
smooth <-function (start,window) {
	limit = length(rval[,2])
	if (start <= limit - window+1)
		return(sum(rval[start:(start+window-1), 2]*rval[start:(start+window-1),4])/sum(rval[start:(start+window-1), 4]))
	
	#if at end, wrap around to the front of probe
	wrap = start - (limit - window +1)
	return(sum(c(rval[start:limit,2]*rval[start:limit,4],  rval[1:wrap,2]*rval[1:wrap,4]))/sum(c(rval[start:limit,4], rval[1:wrap,4])))
}


#standard errors
smoothSE <-function (start,window) {
	limit = length(rval[,2])
	if (start <= limit - window+1)
		return(sum(rval[start:(start+window-1), 3]*sqrt(rval[start:(start+window-1),4]))/sqrt(sum(rval[start:(start+window-1), 4])))
	
	#wrap around to the front of probe
	wrap = start - (limit - window +1)
	return(sum(c(rval[start:limit,3]*sqrt(rval[start:limit,4]),  rval[1:wrap,3]*sqrt(rval[1:wrap,4])))/sqrt(sum(c(rval[start:limit,4], rval[1:wrap,4]))))
}

#run
rval = read.table("pos_v_rval2.txt", header=T)
windowsize = 5
rval.smooth=c()
rval.smoothSE = c()
for (i in 1:60){
	rval.smooth = c(rval.smooth, smooth(i,windowsize))
	rval.smoothSE = c(rval.smoothSE, smoothSE(i,windowsize))
}

plotSmoothed<-function(windowsize, errorbars=FALSE){
	window = windowsize
	rval.smooth=c()
	rval.smoothSE = c()
	for (i in 1:60){
		rval.smooth = c(rval.smooth, smooth(i,windowsize))
		rval.smoothSE = c(rval.smoothSE, smoothSE(i,windowsize))
	}
	title = "Rvalue v Mismatch Position for Mouse-Hamster "
	plot(seq(1,60),rval.smooth,ylim=c(-1.2,1.2),xlab="position",ylab="Rvalue",main=title)
	if (errorbars)
	arrows(seq(1,60),rval.smooth-rval.smoothSE,seq(1,60),rval.smooth+rval.smoothSE,angle=90,code=3,length=0.01)
}
