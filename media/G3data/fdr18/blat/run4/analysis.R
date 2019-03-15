# load the data
neg = read.table("neg.txt")
pos = read.table("pos.txt")

# hist of neg and pos
pdf(file="pos_v_neg.pdf")
par(mfrow=c(2,1))
poshist = hist(pos[,2], freq=F, col="red", xlim=c(1,50), ylim=c(0,.15),breaks=35, xlab="match")
#par(new=T)
neghist = hist(neg[,2], freq=F, col="grey", xlim=c(1, 50), ylim=c(0,0.15), breaks=35, xlab="match")
par(mfrow=c(1,1))
dev.off()

#plot diff
plot(seq(1,34), poshist$density - neghist$density, type="l")

#plot ecdf for pos v neg
pdf("cum_pos_v_neg.pdf")
neg.e = ecdf(neg[,2])
pos.e = ecdf(pos[,2])
plot(neg.e, col="grey", pch="n", main="", ylim=c(0,1), xlab="matches")
par(new=T)
plot(pos.e, col="red", pch="p", main="", ylim=c(0,1), xlab="")
title(" pos v neg cis alpha match")
dev.off()

# pvals are always nonsignif by T-test on indiv histogram
# modes and ks.test on ecdf
#turn into pdf


# looking at relationship between match and alpha
# column 3=human alpha, col4 = mouse alpha
negmatch = read.table("neg_match_v_alpha.txt")
negremove = negmatch[,4]>0 | negmatch[,3] > 0
negremove = !negremove

posmatch = read.table("pos_match_v_alpha.txt")
posremove = posmatch[,4]<0 | posmatch[,3] < 0
posremove = !posremove

par(mfrow = c(2,1))

pdf(file="pos_match_v_alpha.pdf", version="1.4")
#pos match
plot(posmatch[posremove,2], posmatch[posremove,3], col="#ff000090", xlim=c(15,50), ylim=c(-2.1, 12), xlab="match", ylab="alpha")
par(new=T)
plot(posmatch[posremove,2], posmatch[posremove,4], col="#c0c0c090", xlim=c(15,50), ylim=c(-2.1, 12), pch="x", xlab="", ylab="")
dev.off()

pdf(file="neg_match_v_alpha.pdf", version="1.4")
#neg match
plot(negmatch[negremove,2], negmatch[negremove,4], col="#c0c0c088", xlim=c(15,50), ylim=c(-2.1, 2), pch="x", xlab="", ylab="")
par(new=T)
plot(negmatch[negremove,2], negmatch[negremove,3], col="#66000033", xlim=c(15,50), ylim=c(-2.1, 2), xlab="match", ylab="alpha")
dev.off()

#qplot version
all = read.table("combined_match_v_alpha.txt")
all.x = c(all[,2], all[,2])
all.index = c(rep(1,5330), rep(2,5330))
all.data = as.data.frame(cbind(all.x, c(all[,3], all[,4]), all.index))
names(all.data) = c("match", "alpha", "group")
qplot(match, alpha, data=all.data, colour=group, alpha=I(3/10))
ggsave(file="match_v_alpha.png", dpi=72)
# correlation of all match v all alphas is -0.03
# linear regression slope is almost zero
