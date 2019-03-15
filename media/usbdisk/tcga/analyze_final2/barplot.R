## load functions
source("/media/usbdisk/4analyses/barplot_functions.R")

## Clean usage
sdir = "/media/usbdisk/tcga/analyze_final2/within2mbclin/"
tcga.m = read.table(paste(sdir, "male_cis_with_pos.txt", sep=""))
namelist = c("chrom", "start", "stop", "symbol", "index", "marker", "mu", "alpha", "r", "nlp")
names(tcga.m) = namelist
makeBarPlots(tcga.m, title="log2(3/2) TCGA M cis clinical", autoX=T, posNeg=T)
dev.print(device=pdf, file="within2mbclin/tcga_m_cis_2mb_clin.pdf")

tcga.f = read.table(paste(sdir, "female_cis_with_pos.txt", sep=""))
names(tcga.f) = namelist
makeBarPlots(tcga.f, title="log2(3/2) TCGA F cis clinical", autoX=T, posNeg=T)
dev.print(device=pdf, file="within2mbclin/tcga_f_cis_2mb_clin.pdf")

sdirOld = "/media/usbdisk/tcga/analyze_final2/within2mbX/"
tcga.all = read.table(paste(sdirOld, "all_cis_with_pos.txt", sep=""))
names(tcga.all)  = namelist
makeBarPlots(tcga.all, title="log2(3/2) TCGA MF cis")

