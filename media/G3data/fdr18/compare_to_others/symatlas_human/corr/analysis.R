gnf = read.table("../GNF1Hdata.txt")

gnfT = read.table("GNF1Hdata_invert.txt", header=T)
tapply(gnfT$conditiono

# split and aggregate
z = split(x, x$col)
z.l = lapply(z, function(.data){
  .agg = colMeans(.data[, c(1,4:8)], na.rm=TRUE)
  data.frame(.data[1, 2], .data[1, 3], lapply(.agg, unlist))
  ))
do.call(rbind, z.1)
#https://stat.ethz.ch/pipermail/r-help/2008-July/168695.html
