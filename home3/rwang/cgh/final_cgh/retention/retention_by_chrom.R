#create barplot of retention by chrom
library(sciplot)
g3rf = read.table("g3retention_freq.txt")
names(g3rf) = c("id", "chrom", "start", "stop", "rf")
bargraph.CI(chrom, rf, data = g3rf, ylab="Retention Frequency", err.width=0.06, main="Retention frequency by chromosome")

dev.print(device=pdf, file="retention_by_chrom.pdf")
