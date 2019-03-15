#5/12/10
#
# for RH and TCGA cancer
# plot the Ratio of:
# 1. number of pos alpha genes to number of neg alpha genes by chrom
# 2. 

###
# human RH data
##
data = read.table("../cis_FDR40.txt")
geneperchrom=c(
2059, 1354, 1182, 789, 966, 1108, 971,
749, 853, 778, 1352, 1109, 386,
672, 619, 875, 1201, 305, 1401,
688, 292, 480, 784, 23)

#ea num is end of chromN
breaks = c(
0,
2059, 3413, 4595, 5384, 6350, 7458,
8429, 9178, 10031, 10809, 12161, 13270,
13656, 14328, 14947, 15822, 17023, 17328,
18729, 19417, 19709, 20189, 20973, 20996
)

res = data.frame("meanall"=rep(0,24), "sdall"=rep(0,24), "meannegs"=rep(0,24), "sdnegs"=rep(0,24), "meanpos"=rep(0,24), "sdpos" = rep(0,24), "numpos"=rep(0,24), "numnegs"=rep(0,24))

for (i in 2:25){

	idx = which(data[,1]>breaks[i-1] & data[,1]<=breaks[i])
	#cat(sum(idx),"\n")
	res[i-1,1] = mean(data[idx,3])
	res[i-1,2] = sd(data[idx,3])/sqrt(length(data[idx,3]))
        negs = which(data[idx,3]<0)
        pos  = which(data[idx,3]>0)
        negs1 = idx[negs]
        pos1 = idx[pos]
        res[i-1,3] = mean(abs(data[negs1,3]))
        res[i-1,4] = sd(abs(data[negs1,3]))/sqrt(length(data[negs1,3]))
        res[i-1,5] = mean(data[pos1,3])
        res[i-1,6] = sd(abs(data[pos1,3]))/sqrt(length(data[pos1,3]))
        res[i-1,7] = length(pos)
        res[i-1,8] = length(negs)
}


###
### TCGA all data
tcga.all = read.table("/media/usbdisk/tcga/regression/autosomes/cis_with_pos.txt")
names(tcga.all) = c("chrom", "start", "stop", "symbol", "index", "marker", "mu", "alpha", "nlp")

###
### TCGA female
tcga.female = read.table("/media/usbdisk/tcga/analyze2/female_cis_with_pos.txt")
names(tcga.female) = c("chrom", "start", "stop", "symbol", "index", "marker", "mu", "alpha", "nlp")

###
### TCGA male
tcga.male = read.table("/media/usbdisk/tcga/analyze2/male_cis_with_pos.txt")
names(tcga.male) = c("chrom", "start", "stop", "symbol", "index", "marker", "mu", "alpha", "nlp")

# Function to count genes, get mean pos/neg alpha
# give it tcga.female or tcga.male to return data frame
splitDataPosNeg <- function(cis){
  data = data.frame("meanall"=rep(0,24), "sdall"=rep(0,24), "meannegs"=rep(0,24), "sdnegs"=rep(0,24), "meanpos"=rep(0,24), "sdpos"=rep(0,24), "numpos"=rep(0,24), "numnegs"=rep(0,24))
  for(i in 1:24){
    idx = which(cis$chrom == i)
    data[i, 1] = mean(cis$chrom==i)
    data[i, 2] = sd(cis$alpha[idx])/sqrt(length(idx))
    negs = which(cis$alpha[idx]<0)
    pos = which(cis$alpha[idx]>0)
    negs1 = idx[negs]
    pos1 = idx[pos]
    data[i, 3] = mean(cis$alpha[negs1])
    data[i, 4] = sd(cis$alpha[negs1])/sqrt(length(negs1))
    data[i, 5] = mean(cis$alpha[pos1])
    data[i, 6] = sd(cis$alpha[pos1])/sqrt(length(pos1))
    data[i, 7] = length(pos)
    data[i, 8] = length(negs)
  }
  return(data)
}

###summarize each dataset
cis.all = splitDataPosNeg(tcga.all)
cis.female = splitDataPosNeg(tcga.female)
cis.male = splitDataPosNeg(tcga.male)

####
## ratio number of pos alpha genes to neg alpha genes
cis.all.ratio = cis.all$numpos/cis.female$numnegs
cis.female.ratio = cis.female$numpos/cis.female$numnegs
cis.male.ratio = cis.male$numpos/cis.male$numnegs
rh.ratio = abs(res$numpos/res$numnegs)

pdf(file="cis_ratio_num_posneg.pdf")
barplot(cis.all.ratio, names.arg=seq(1:24), main="cis +/- ratio all TCGA")
barplot(cis.female.ratio, names.arg=seq(1:24), main="cis +/- ratio female TCGA")
barplot(cis.male.ratio, names.arg=seq(1:24), main="cis +/- ratio male TCGA")
barplot(rh.ratio, names.arg=seq(1:24), main="cis +/- ratio human RH")
dev.off()

#####
### calculate and print ratio of pos/neg mean alphas 
cis.all.meanratio = abs(cis.all$meanpos/cis.all$meanneg)
cis.female.meanratio = abs(cis.female$meanpos/cis.female$meanneg)
cis.male.meanratio = abs(cis.male$meanpos/cis.male$meanneg)
# radiation hybrid
rh.ratio = abs(res$meanpos/res$meannegs)

#pdf(file="cis_ratio_mean_posneg.pdf")
barplot(cis.all.ratio, names.arg=seq(1:24), main="cis +/- ratio all TCGA")
barplot(cis.female.ratio, names.arg=seq(1:24), main="cis +/- ratio female TCGA")
barplot(cis.male.ratio, names.arg=seq(1:24), main="cis +/- ratio male TCGA")
barplot(rh.ratio, names.arg=seq(1:24), main="cis +/- ratio human RH")
#dev.off()
