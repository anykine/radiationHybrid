# load in the finemapped hum/mouse blocks
x1 = read.table("20090313finemap_1to1.txt")
x2 = read.table("20090313finemap_manyto1.txt")
mydata = list(single=x1, many = x2)

# pick (1)1to1 or (2)many to 1 mapping of Mouse to Human blocks
histMHblock <- function (data=mydata, i=1,ranges=c(-1e6,1e6),bw=1e4){
#i = 1
#r = c(-1e5,1e5)
#bw=1e4
xr = range(data[[i]][,3])
br = seq(xr[1]-bw, xr[2]+bw, by=bw)
h=hist(data[[i]][,3], breaks=br, col="red", xlim=ranges,xlab="diff in distance",main="Distance between Mouse and Human blocks",plot=F)
id = which(h$breaks > ranges[1] & h$breaks < ranges[2])
#dev.print(file="dist_bt_MH_blocks.pdf", device=pdf)
return(list(hist=h,id=id))
}

#genereate the data for radius v counts
makePlot <- function(data=mydata,start=1e4,end=1e7,by=1e7){
  within = seq(start,end,by)
  store = matrix(0,length(within),2)
  for (i in 1:length(within)){
    lim = c(-within[i], within[i])
    a = histMHblock(data, i=1,ranges=lim, bw=1e4)
    store[i,2] = sum(a[['hist']]$counts[a[['id']]])
    store[i,1] = lim[2]
    cat(i,"\n")
  }
  plot(store[,1], store[,2], type="l", xlab="within", ylab="counts")
  return(store)
}

# plot the output ot makePlot
plotcount <- function(data,xlimit=c(0,1e7),step=2e5){
  plot(data[,1], data[,2], type="l", xlab="within (kb)", ylab="counts", main="mouse human dist b/t peaks",xaxt="n",yaxt="n",xlim=xlimit)
  xax = seq(1e4,xlimit[2],by=step)
  xax = xax/1000
  axis(1,at=seq(1e4,xlimit[2],by=step),labels=xax,las=2,cex.axis=0.5)
  axis(2,at=seq(1,400,by=10),las=2,cex.axis=0.5)
}


# what's the average distance bt blocks
mhblocks = read.table("../blocks_MH_300k1.txt", sep=" ")
mhblocks.mean = mean(mhblocks[,3])
mhblocks.median = median(mhblocks[,3])
# what's avg size of human block
hblocks = read.table("../zero_gene_peaks_ranges300k.txt")
hblocks.mean = mean(hblocks[,6]-hblocks[,3])
hblocks.median = median(hblocks[,6]-hblocks[,3])
# what's avg size of mouse block
mblocks = read.table("../../mouse/unique/zero_gene_peaks_ranges300k.txt")
mblocks.mean = mean(mblocks[,6]-mblocks[,3])
mblocks.median = median(mblocks[,6]-mblocks[,3])
# avg dist b/t peaks or ortho blocks
obmany = read.table("20090313finemap_manyto1.txt")
obmany.mean = mean(obmany[,3])
obmany.median = median(obmany[,3])
obone = read.table("20090313finemap_1to1.txt")
obone.mean = mean(obone[,3])
obone.median = median(obmany[,3])
