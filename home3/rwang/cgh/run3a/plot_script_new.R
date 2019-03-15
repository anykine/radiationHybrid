# R script to plot CGH array data in terms of log10(Cy5/Cy3)
# marker retention is plotted at y=-1 where applicable
#script is depstopent on these two files:  
#log_ratios_and_posns_on_CGH.txt and mm7_retention.txt

#run the following two commands in your R shell indepstopent of the script
#to make script faster ... otherwise uncomment the following two lines

#cgh=read.table("batch2_smoothed.txt", header=T)
#cghbin=read.table("batch2_binned.txt", header=T)

cgh=read.table("batch3a_smoothed2.txt", header=T)
cghbin=read.table("batch3a_binned.txt", header=T)

cgh_names=names(cgh)[4:length(names(cgh))]
cghbin_names=names(cghbin)[6:length(names(cghbin))]

cell_num=length(cgh_names);
freq=matrix(0,cell_num,2)

for (n in 1:cell_num) {

	#markers=read.table("mm7_retention.txt", header=T)
	#CHANGEABLE... title of experiment, graphs, filenames
     title_c=paste("RH_",cgh_names[n],"_vs_A23", sep="");     
	
	# CHANGEABLE ...  the retention pattern of the cell line of interest ... cell line always prefixed with the letter c (e.g. c50 or c29) -  comment out this line if plotting a control experiment 
	cghline=cghbin[cghbin_names[n]];
	pcrline=cghbin[cghbin_names[n+cell_num]];

# store all chromosomes as a list to loop over
	chromes=list("chr01", "chr02", "chr03", "chr04", "chr05", "chr06", "chr07", "chr08", "chr09", "chr10", "chr11", "chr12", "chr13", "chr14", "chr15", "chr16", "chr17", "chr18", "chr19", "chr20", "chr21", "chr22", "chrX", "chrY") 

	current=getwd()
	dir.create(title_c)
	setwd(title_c)

	for (i in 1:length(chromes)) {
		# current chromosome in for loop 
		chr=as.character(chromes[i]);
		# title of graph 
		title=paste(title_c, chr);
		#title of output file
		name=paste(title, ".pdf", sep="")
	
		#function to plot to file comment out if you wish to graph this manually
		pdf( file=name, width = 8.5, height = 11 ) 
	
		# add xlim argument if you wish to restrict plot to area smaller than chromosome
		plot(cgh$start[cgh$chr==chr],cgh[,cgh_names[n]][cgh$chr==chr], pch=".", ylim=c(-1.0,1.6), main=title, xlab="chromosome bp posn", ylab="log10(cy5/cy3)" )


		# plots marker retention as segments 
		#don't run this if it is a control experiment - comment out
		# you don't need to add xlim argument as plot function sets initial dimensions
		if (length( cghbin$start[cghbin$chr==chr & pcrline==0] )>0) {
		segments(cghbin$start[cghbin$chr==chr & pcrline==0], rep(-.55, length(cghbin$start[cghbin$chr==chr & pcrline==0])),cghbin$stop[cghbin$chr==chr & pcrline==0] , rep(-.55, length(cghbin$start[cghbin$chr==chr & pcrline==0])), lwd=2, col="blue")
		}
	
		if (length( cghbin$start[cghbin$chr==chr & pcrline==1] )>0) {
		segments(cghbin$start[cghbin$chr==chr & pcrline==1], rep(-.50, length(cghbin$start[cghbin$chr==chr & pcrline==1])),	cghbin$stop[cghbin$chr==chr & pcrline==1], rep(-.55, length(cghbin$start[cghbin$chr==chr & pcrline==1])), lwd=2, col="red")
		}

		if (length(cghbin$start[cghbin$chr==chr & pcrline==2]) >0) {
			segments(cghbin$start[cghbin$chr==chr & pcrline==2], rep(-.6, length(cghbin$start[cghbin$chr==chr & pcrline==2])),	cghbin$stop[cghbin$chr==chr & pcrline==2], 	rep(-.6, length(cghbin$start[cghbin$chr==chr & pcrline==2])), lwd=2, col="yellow" )
		}	

#tracks of loss and gain and concordance

		if (length(cghbin$start[(cghbin$chr==chr & cghline==1) & pcrline==1])>0) {
			segments(cghbin$start[(cghbin$chr==chr & cghline==1) & pcrline==1], rep(1.5, length(cghbin$start[(cghbin$chr==chr & cghline==1) & pcrline==1])),	cghbin$stop[(cghbin$chr==chr & cghline==1) & pcrline==1], rep(1.5, length(cghbin$start[(cghbin$chr==chr & cghline==1) & pcrline==1])), lwd=2, col="green")
		}
		if (length(cghbin$start[(cghbin$chr==chr & cghline==1) & pcrline==0])>0) {
			segments(cghbin$start[(cghbin$chr==chr & cghline==1) & pcrline==0], rep(1.45, length(cghbin$start[(cghbin$chr==chr & cghline==1) & pcrline==0])),	cghbin$stop[(cghbin$chr==chr & cghline==1) & pcrline==0], rep(1.45, length(cghbin$start[(cghbin$chr==chr & cghline==1) & pcrline==0])), lwd=2, col="yellow")
		}
		if (length(cghbin$start[(cghbin$chr==chr & cghline==0) & pcrline==1])>0) {
			segments(cghbin$start[(cghbin$chr==chr & cghline==0) & pcrline==1], rep(1.55, length(cghbin$start[(cghbin$chr==chr & cghline==0) & pcrline==1])),	cghbin$stop[(cghbin$chr==chr & cghline==0) & pcrline==1], rep(1.55, length(cghbin$start[(cghbin$chr==chr & cghline==0) & pcrline==1])), lwd=2, col="red")
		}

	dev.off()
}
setwd(current)



	freq[n,1]= length(cghbin$start[cghline[,1]==0 & pcrline[,1]==1])/length(cghbin$start[pcrline[,1]==1])
	freq[n,2]= length(cghbin$start[cghline[,1]==1 & pcrline[,1]==0])/length(cghbin$start[pcrline[,1]==0])

}
write.table(cbind(cgh_names,freq), file="loss_gain.txt", sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE) 
#Key for variable cgh (see names(cgh))
#probe information retained as chr = chromosome, start=chromosome start, stop=chromosome stop
#logratio retained as N where N is:
#		c89: RH89/A23
#		e41: A23/Hamster
#		c8: RH8/A23
#		c23: RH23/A23
#		e53: Mouse/A23
#		c55: RH55/A23
#		c65: RH65/A23


# modified moving average function (column,windowsizein) fix if window not even number of base pairs

	#moving.average <- 
	#function(x, k) { 
	#	n <- length(x)  
	#	y <- rep(0, n)   
	#	for (i in (k/2):(n-5) )  
	#		y[i] <- mean(x[ ((i-k/2)+1) : (i+(k/2))  ]) 
	# 	return(y) 
# } 

# lines marked CHANGEABLE are meant to be modified for each experiment 
# you wish to plot
#for (i in names(cgh)[(4:10)] ) {  

# CHANGEABLE... cgh data... log(base10) ratios of cy5/cy3 for experiment of interest (see key at bottom of file)
	#	line_log_ratios=cgh$c8;	

# calculate the average for ten probes on tiling array - for experiment of interest
	#	cghavg=moving.average(line_log_ratios,10);
	#	cghcom=cbind(cgh,cghavg);
# if you don't want a sliding window comment out the above two lines and uncomment following two lines (this is dumb needs fixing)
	#cghavg=line_log_ratios;
	#cghcom=cbind(cgh,cghavg);


