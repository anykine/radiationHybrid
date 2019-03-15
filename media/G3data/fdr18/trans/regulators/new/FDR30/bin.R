# bin the human regulators and mouse regulators
# to find regions of conserved regulation.
# mouse was liftovered to human hg18

m = read.table("mouse2hum_FDR40_counts.sorted")
names(m) = c("chrom", "start", "stop", "index", "counts")
h = read.table("hum_FDR30_counts.txt")
names(h) = c("index", "chrom", "start", "stop", "counts")

#get chrom sizes from db
library(RMySQL)
#con = dbConnect(MySQL(), user="root", password="smith1", dbname="retention_frequency")
con = dbConnect(MySQL(), user="root", password="smith1", dbname="g3data")
chrs = dbGetQuery(con, "select chrom,size from hg18chrsize")


hbin = list()
mbin = list()

binsize = 1e6

for (i in 1:24){
  m1 = which(m$chrom==i)
  h1 = which(h$chrom==i)
  sz = ceiling(chrs$size[i])
  htmp = trunc(h$start[h1]/binsize)
  mtmp = trunc(m$start[m1]/binsize)
  htab = tabulate(htmp, nbins = ceiling(sz/binsize))
  mtab = tabulate(mtmp, nbins = ceiling(sz/binsize))
  hbin[[i]] = htab
  mbin[[i]] = mtab
}

#do correlations by chrom
for (i in 1:24){
  ## if (length(hbin[[i]]) == length(mbin[[i]]) ){
  ##   cat(i, "agree\n")
  ## } else {
  ##   cat(i, "disagree\n")
  ## }
  a = cor.test(hbin[[i]], mbin[[i]])
  cat(i,"\n")
  cat("r = ", a$estimate, "\n")
  cat("p = ", a$p.value, "\n")
}

#omnibus across all bins
cor.test(unlist(hbin), unlist(mbin))
# cor 0.14, p=3.1e-15

### scratch
m1 = which(m$chrom==7)
h1 = which(h$chrom==7)
plot(h$start[h1], h$counts[h1], ylim=c(0,120), col="red")
par(new=T)
plot(m$start[m1], m$counts[m1], ylim=c(0,120), col="blue")


chrbin = chrs[7,2]/1e6
is.between = function(x, a, b){
  (x - a) * (b - x) > 0
}
