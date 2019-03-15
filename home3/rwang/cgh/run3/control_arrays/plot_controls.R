# R script to plot CGH array data in terms of log10(Cy5/Cy3)
# this is only for control arrays:
# 1. Human v A23
# 2. Hamster v A23
# 3. Hamster v Human
#logratio is Cy5 to Cy3. A23 is always Cy3
#cgh=read.table("batch3_smoothed2noctl.txt", header=T)
#cghbin=read.table("batch3_binned.txt", header=T)
cgh = read.table("ctrl.data", header=T,sep="\t")
cgh_names=names(cgh)[4:length(names(cgh))]
cell_num=length(cgh_names);

for (n in 1:cell_num) {
	cat("working on ", n, "\n")
	#markers=read.table("mm7_retention.txt", header=T)
	#CHANGEABLE... title of experiment, graphs, filenames
		if(as.character(cgh_names[n]) == "c90") { 
		 	title_c = "Human_v_a23"
			cat("title set to humva23\n")
		}
		
		if(as.character(cgh_names[n]) == "c91") { 
			title_c = "Hamster_v_a23"
			cat("title set to hamva23\n")
		}
		if(as.character(cgh_names[n]) == "c92") { 
			title_c = "Hamster_v_Human"
			cat("title set to hamvhum\n")
		}
	
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

		#make pdfs
		#name=paste(title, ".pdf", sep="")
		#function to plot to file comment out if you wish to graph this manually
		#pdf( file=name, width = 8.5, height = 11 ) 

		#make jpegs
		name=paste(title, ".jpg", sep="")
		jpeg(file=name, width=1024,height=768)	
		# add xlim argument if you wish to restrict plot to area smaller than chromosome
		plot(cgh$start[cgh$chr==chr],cgh[,cgh_names[n]][cgh$chr==chr], pch=".", ylim=c(-1.0,1.6), main=title, xlab="chromosome bp posn", ylab="log10(cy5/cy3)" )

	dev.off()
}
setwd(current)


}
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


