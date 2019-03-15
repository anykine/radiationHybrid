#histogram of permutation versus observed cis alphas
null = read.table("cis_null_distrib.txt.norm")
obs = read.table("cis_obs_distrib.txt.norm")
x = seq(2000,10000)
x.range = seq(2000,10000)
y.limit = c(0,0.005)
plot(x, obs[x.range,1], ylim=y.limit, lty=1, col="red", type="h")
par(new=T)
plot(x, null[x.range,1], ylim=y.limit, lty=2, type="l")
