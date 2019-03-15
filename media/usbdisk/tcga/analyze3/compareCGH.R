#compare level2 CGH (lowess) v level1 CGH (median/self) normalizations

# load median normalized level1 CGH
cgh.10a = read.table("cgh.10only")
# for some reason, the sign is flipped on this normalization
cgh.10a = cgh.10a * -1
headera = read.table("/media/usbdisk/tcga/cgh/level1/cghcall/header")
names(cgh.10a) = as.character(unlist(c(headera)))

# load level2 CGH
cgh.10b = read.table("/media/usbdisk/tcga/analyze2/cgh.10only")
headerb = read.table("/media/usbdisk/tcga/header240")
names(cgh.10b) = as.character(unlist(c(headerb)))


idx = match(names(cgh.10a), names(cgh.10b))
corrs = vector(length=length(idx)-4, mode="numeric")
for (i in 5:length(idx)){
  a = cor.test(cgh.10a[,i], cgh.10b[, idx[i]])
  corrs[i-4] = a$estimate
  cat(a$estimate, "\t", a$p.value, "\n")
}

########################
# try all data at once
cgha = read.table("/media/usbdisk/tcga/cgh/level1/cghcall/all.cghcall.log2ratios.pos.txt", header=T)
cgha = cgha * -1
#headera = read.table("/media/usbdisk/tcga/cgh/level1/cghcall/header")
cghb = read.table("/media/usbdisk/tcga/analyze2/all.cgh.txt")
headerb = read.table("/media/usbdisk/tcga/header240")
names(cghb) = as.character(unlist(c(headerb)))

probeids = match(cgha[,1], cghb[,1])
for (i in 5:length(idx)){
  a = cor.test(cgha[,i], cghb[probeids, idx[i]])
  corrs[i-4] = a$estimate
  cat(a$estimate, "\t", a$p.value, "\n")
}

## correlation are all around 0.9
hist(corrs, breaks=40, main="correlation normL1 v L2 CGH")
dev.print(device=pdf, file="correlation_normL2vL2CGH.pdf")
