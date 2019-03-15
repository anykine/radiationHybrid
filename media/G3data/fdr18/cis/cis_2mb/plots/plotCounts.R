### 9/2/10
### plot number of cis/trans peaks for varying FDR

dat = read.table("cis_trans_counts.txt", header=T)
dat = cbind(dat, numLociLog = log10(dat$numLoci))
fdr = c(1, 5, 10, 20, 30, 40)
nlp = -log10(subset(dat$Pval, dat$type %in% c("trans")))

par(mar=c(5,4,4,4))
## PLOT TRANS
plot(subset(dat[, c(5,7)], dat$type %in% c("trans")), xaxt="n", yaxt="n", ylab="", xlab="", type="b", col="blue", lwd=3)
#xaxis: FDR and nlp
axis(side=1, at=fdr, cex.axis=0.7)
mtext(round(rev(nlp),1), side=1, at=fdr, line=2, cex=0.7)
mtext("trans FDR (%)/ -log P", side=1, line=3, cex=0.7)
#yaxis
axis(side=2, at=0:6, cex.axis=0.8, las=2)
mtext("trans counts (log10)", side=2, line=2, cex=0.8)

## PLOT CIS
## to plot cis2mb, need to scale data onto this same framework
#x axis
nlp.cis = -log10(subset(dat$Pval, dat$type %in% c("cis2mb")))
axis(side=3, at=fdr, cex.axis=0.7)
mtext(round(rev(nlp.cis),1), side=3, at=fdr, line=2, cex=0.7)
mtext("cis FDR (%)/ -log10 P", line=3, cex=0.7)
#y axis
counts.cis = subset(dat$numLoci, dat$type %in% c("cis2mb"))
#scale data to trans yaxis
#empiracle determination to scale cis2mb data to [0,5] using counts.cis/470-29.25
#axis(side=4, at=seq(0,5), labels=seq(14136,16536,480), las=2, cex.axis=0.7)
axis(side=4, at=seq(0,5), labels=c(14100, 14600, 15100, 15600, 16100, 16600), las=2, cex.axis=0.7)
mtext("cis counts", side=4, line=2, cex=0.8)
points(subset(dat$FDR, dat$type %in% c("cis2mb")), counts.cis/480-29.25, pch=2, type="b", col="red", lwd=3)

## LEGEND
legend("bottomright", legend=c("cis", "trans"), col=c("red", "blue"), lty=1, pch=c(2,1))

dev.print(device=pdf, file="cis_trans_fdr.pdf")
