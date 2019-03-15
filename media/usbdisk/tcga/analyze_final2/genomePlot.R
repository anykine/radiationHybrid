#################################
# plots alphas across the genome
#

namelist = c("chrom", "start", "stop", "symbol", "index", "marker", "mu", "alpha", "r", "nlp")

##TCGA
sdirTCGA = "/media/usbdisk/tcga/analyze_final2/within2mbX/"
tcga.all = read.table(paste(sdirTCGA,"all_cis_with_pos.txt", sep=""))
names(tcga.all) = namelist
tcga.all.gc = makeGC(tcga.all)
plot(tcga.all.gc$gc, tcga.all.gc$alpha, pch=".", cex=2, main="TCGA combined")
#plot(tcga.all$alpha, pch=".", cex=2, main="TCGA combined")
tcga.thresh5 = 1.69
tcga.all.gc5 = tcga.all.gc[which(tcga.all.gc$nlp > tcga.thresh5),]

tcga.m = read.table(paste(sdirTCGA,"male_cis_with_pos.txt", sep=""))
names(tcga.m) = namelist
tcga.m.gc = makeGC(tcga.m)
plot(tcga.m.gc$gc, tcga.m.gc$alpha, pch=".", cex=2)

tcga.f = read.table(paste(sdirTCGA,"female_cis_with_pos.txt", sep=""))
names(tcga.f) = namelist
tcga.f.gc = makeGC(tcga.f)

##HAPMAP
sdirHapmap = "/media/usbdisk/cnv/www.sanger.ac.uk/analyze_final2/within2mbX/"
hapmap.all = read.table(paste(sdirHapmap,"all_cis_with_pos.txt", sep=""))
names(hapmap.all) = namelist
hapmap.all.gc = makeGC(hapmap.all)
plot(hapmap.all.gc$gc, hapmap.all.gc$alpha, cex=2, pch=".")
hapmap.thresh5 = 2.3
hapmap.all.gc5 = hapmap.all.gc[which(hapmap.all.gc$nlp > hapmap.thresh5),]

hapmap.m = read.table(paste(sdirHapmap,"male_cis_with_pos.txt", sep=""))
names(hapmap.m) = namelist
hapmap.m.gc = makeGC(hapmap.m)
plot(hapmap.m$alpha, pch=".", cex=2)

hapmap.f = read.table(paste(sdirHapmap,"female_cis_with_pos.txt", sep=""))
names(hapmap.f) = namelist
hapmap.f.gc = makeGC(hapmap.f)

##RH
sdirRH = "/media/G3data/fdr18/cis/comp_MH_cis_alphas/"
RH = read.table(paste(sdirRH, "comp_hum_mouse_FDR40_symbol_with_pos.sort.txt", sep=""))
namelist.rh  =c("chrom", "start", "stop", "humgene", "humalpha", "musgene", "musalpha", "symbol")
names(RH) = namelist.rh
RH.gc = makeGC(RH)
plot(RH.gc$gc, RH.gc$humalpha, pch=".", ylim=c(-2,4))
plot(RH.gc$gc, RH.gc$musalpha, pch=".", ylim=c(-2,4))
RH.thresh5 = 1.92
##crap - i need -logp for RH, so I can thresh. need fdr cutoffs for mouse.

##########
## allplots
plot(tcga.all.gc$gc, tcga.all.gc$alpha, pch=".",xaxt="n", cex=2, main="alphas across genome", ylim=c(-2,4),col="blue")
axis(1, at = sums[1:24], labels=seq(1,24))
points(hapmap.all.gc$gc, hapmap.all.gc$alpha, cex=2, pch=".", col="red")
points(RH.gc$gc, RH.gc$humalpha, pch=".", cex=2, col="green")
points(RH.gc$gc, RH.gc$musalpha, pch=".", cex=2, col="orange")
lines(lowess(tcga.all.gc$gc, tcga.all.gc$alpha, f=0.1), col="blue", lwd=2)
lines(lowess(hapmap.all.gc$gc, hapmap.all.gc$alpha, f=0.1), col="red", lwd=2)
lines(lowess(RH.gc$gc, RH.gc$humalpha, f=0.1), col="green", lwd=2)
lines(lowess(RH.gc$gc, RH.gc$musalpha, f=0.1), col="orange", lwd=2)
legend("topleft", c("TCGA", "Hapmap", "G3", "T31"), fill=c("blue", "red", "green", "orange"))

#-male
plot(tcga.m.gc$gc, tcga.m.gc$alpha, pch=".",xaxt="n", cex=2, main="Male", ylim=c(-2,4),col="blue")
axis(1, at = sums[1:24], labels=seq(1,24))
points(hapmap.m.gc$gc, hapmap.m.gc$alpha, cex=2, pch=".", col="red")
lines(lowess(tcga.m.gc$gc, tcga.m.gc$alpha, f=0.1), col="blue", lwd=2)
lines(lowess(hapmap.m.gc$gc, hapmap.m.gc$alpha, f=0.1), col="red", lwd=2)
#-female
plot(tcga.f.gc$gc, tcga.f.gc$alpha, pch=".",xaxt="n", cex=2, main="Female", ylim=c(-2,4),col="blue")
axis(1, at = sums[1:24], labels=seq(1,24))
points(hapmap.f.gc$gc, hapmap.f.gc$alpha, cex=2, pch=".", col="red")
lines(lowess(tcga.f.gc$gc, tcga.f.gc$alpha, f=0.1), col="blue", lwd=2)
lines(lowess(hapmap.f.gc$gc, hapmap.f.gc$alpha, f=0.1), col="red", lwd=2)

#-all 5% fdr
plot(tcga.all.gc5$gc, tcga.all.gc5$alpha, pch=".",xaxt="n", cex=2, main="MF", ylim=c(-2,4),col="blue")
axis(1, at = sums[1:24], labels=seq(1,24))
points(hapmap.all.gc5$gc, hapmap.all.gc5$alpha, cex=2, pch=".", col="red")
points(RH.gc$gc, RH.gc$humalpha, pch=".", cex=2, col="green")
points(RH.gc$gc, RH.gc$musalpha, pch=".", cex=2, col="orange")
## nee





############################
# FUNCTIONS
#

makeGC = function(table){
  chromSize = "/home3/rwang/rhvec/chrom_size_human_36.txt"
  cs = read.table(chromSize)
  sums = c(0, cumsum(as.numeric(cs[,2])))
  chroms = table$chrom 
  len  = dim(table)[1]
  gc = rep(0, len)
  for (i in 1:len){
    gc[i] = table$start[i] + sums[chroms[i]]
  }
  return(cbind(gc,table))
}
