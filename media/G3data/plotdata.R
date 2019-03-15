#automagically create the plot

# file format is position | 
plotdata <- function(filename){
  data = read.table(filename)
  fname = unlist(strsplit(filename, ".", fixed=T))[1]
  pdf(paste(fname, ".pdf", sep=""))
  ident = unlist(strsplit(filename, "plotdata", fixed=T))[2]
  plot(data[,1]/1000000, data[,2], pch=".", col="blue", xlab = "Position (MB)", ylab = "-log10 P", main=paste("marker/gene", ident, sep=" "))
  dev.off()
}

### making it callable
args = commandArgs()
plotdata(args[2])
