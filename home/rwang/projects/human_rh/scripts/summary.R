# read in and summarize illumina data
#this is all a23 controls 
x = read.table("a23_control_compare.txt", header=T)
names(x) = c("target", "c1", "c2", "c3", "c4", "c5", "c6", "c7")
#tab gives me column names
headers = names(x)[2:length(x)]

#
#getsummaries
#get summary stats for each control
getsummaries <-function(cols=headers,data=x){
	i =1 
	while(i <= length(cols) ){
		dat = summary(data[,cols[i]] )
		print(dat)
		dat = sd(data[,cols[i]] )
		print(dat)
		i = i+1
	}
}

#
#plothist()
#plot histograms 6 on a page
plothist <-function(cols=headers,data=x){
	layout(matrix(1:8,2,4))
	for (i in 1:7){
		hist(log10(data[,cols[i]]), breaks=100,xlim=c(1,4.5),ylim=c(1,5000),
			main=paste("A23 intensities ",cols[i]), xlab="log10(intensities)")
	}
}


#
#trimmed.mean()
# drops top and bottom trim.percent
# this is already part of mean function
trimmed.mean <- function(datavector, trim.percent=5) {
	#mean(datavector)
	#calc no. of vals to drop
	dropnumber <- round(trim.percent/100*length(datavector))
	#select out desired vals
 	mean(sort(datavector)[(dropnumber+1):(length(datavector)-dropnumber)])
}
#
#trim.data()
#gets rid of top/bottom percent of dataO
#
trim.data <-function(datavector, trim.percent=5){
	dropnumber <- round(trim.percent/100*length(datavector))
 	sort(datavector)[(dropnumber+1):(length(datavector)-dropnumber)]
}

