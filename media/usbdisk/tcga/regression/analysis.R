# find the overlap in cis values between
# RH(mus/hum), TCGA (gbm)
# all correlations significant p<2.2e-16
# this uses 4662 genes

pdf(file="tcga_v_rh.pdf", version="1.4")
x = read.table("tcga_RH_cis_overlap.txt")
plot(x[,2], x[,4], col=rgb(0,0,1,0.3), xlim=c(-6,10), ylim=c(-6,10))
par(new=T)
plot(x[,2], x[,3], col=rgb(1,0,0,0.3), xlim=c(-6,10), ylim=c(-6,10))
par(new=T)
plot(x[,3], x[,4], col=rgb(0,1,0,0.3), xlim=c(-6,10), ylim=c(-6,10))
title("correlation of cis alphas, RHmus, RHhum, TCGA")
legend("bottomright", c("RHhum v TCGA", "RHmus v TCGA", "RHhum v RHmus"), col=c(rgb(0,0,1), rgb(1,0,0), rgb(0,1,0)),pch="o")
cor.test(x[,2], x[,3])
cor.test(x[,2], x[,4])
fit23 = lm(x[,3]~x[,2])
fit24 = lm(x[,4]~x[,2])
fit34 = lm(x[,4]~x[,3])
abline(fit34)
abline(fit24)
abline(fit23)
dev.off()
