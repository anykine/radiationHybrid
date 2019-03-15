#R code to generate plots of intensities for each CGH array

pdf(file="cgh12up_1.pdf", width=12, height=8.5)
l = matrix(1:12, nrow=3, ncol=4, byrow=T);
layout(l)
nums = c(1:47, 49:75, 77, 79:83);
len = length(nums);
for (i in 1:len){
	if(nchar(i)==1){
		name=paste("rh0", nums[i],sep="")
	} else{
		name=paste("rh",nums[i],sep="")
	}
	cat(name,"\n");
	x= read.table(name);
	#log transform, remove NaN, Inf, -Inf
	a = log10(x[,1])
	mask = is.finite(a)

	hist(a[mask], breaks=100);

	if (i %% 9 == 0) {
		dev.off();
		fname = paste("cgh12up_", i,".pdf", sep="")
		#jpeg(filename=fname, width=1024, height=480);
		pdf(file=fname, width=12, height=8.5);
		layout(l)
	}
}


