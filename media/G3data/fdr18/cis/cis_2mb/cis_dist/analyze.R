# find the dist to cis ceQTL

cdist = read.table("dist_to_cis.txt")
diff = abs(cdist[,2] - cdist[,4])

#need to limit to those cis < 2mb
lim = which(diff < 1.4e6)
res = hist( diff[lim], breaks=50, xaxt="n")
axis(side=1, at=3.5e5*c(0, 1,2,3,4), labels = c(0, 5e5, 1e6, 1.5e6, 2e6))
