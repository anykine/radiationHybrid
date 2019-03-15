# load the data
neg = read.table("neg2.txt")
names(neg) = c("match", "mismatch")
pos = read.table("pos2.txt")
names(pos) = c("match", "mismatch")

# hist of neg and pos
par(mfrow=c(2,1))
poshist = hist(pos[,1], freq=F, col="red", xlim=c(25,50), ylim=c(0,.15))
#par(new=T)
neghist = hist(neg[,1], freq=F, col="grey", xlim=c(25, 50), ylim=c(0,0.15))
par(mfrow=c(1,1))

#plot diff
plot(seq(50-13+1,50), poshist$density - neghist$density, type="l")
