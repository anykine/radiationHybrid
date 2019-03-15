ret = read.table("g3retention_freq.txt")
names(ret) = c("index", "chrom", "start", "stop", "rf")

##database
library(RMySQL)
con = dbConnect(dbDriver("MySQL"), dbname="g3data", username="root", password="smith1")
gc = dbGetQuery(con, paste("select genome_coord from agil_poshg18 order by `index`"))

ret1 = cbind(ret, gc)

#downsample data
ds = subset(ret1, ret1$index %% 100 ==0)
plot(ds[,6], ds[,5], pch=".")
scatter.smooth(ds[,6], ds[,5], span=1/50, pch=".")
dev.print(device=pdf, file="g3retention_freq_plot_smooth.pdf")

##plot
plot(ret1$genome_coord/1e6, ret1$rf, pch=".", cex=3, main="RetFreq", xlab="Genome Coord (Mb)", ylab="RF %")
dev.print(device=pdf, file="g3retention_freq_plot1.pdf")

br = seq(0,1,by=0.02)
hist(ret1$rf, freq=T, col="grey", xlim=c(0,0.5), main="G3 Genomewide Retention", xlab="RF%", las=1)
dev.print(device=pdf, file="g3retention_hist.pdf")
