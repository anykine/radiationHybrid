# closest-gene-to-marker hotspots
# Mouse and Human
d = read.table("hum_mus_regulators.txt")
plot(d[,2], d[,4], pch=".", xlab="human", ylab="mouse")
title("nearest-gene-to-marker hotspots in mouse v human")
correl.p = cor.test(d[,2], d[,4])
correl.s = cor.test(d[,2], d[,4], method="spearman")
abline(lm(d[,4]~d[,2]))
#dev.print(device=pdf, file="hum_mus_hospot.pdf")

