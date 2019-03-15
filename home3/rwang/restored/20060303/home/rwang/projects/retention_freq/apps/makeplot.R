x = read.table("", sep=",")
plot(x[,5]/1000, -log10(y[,3]), pch="*", las=2, xaxt="yes")
b = c(seq(0,1000000000,100000))
axis(side=1, b, cex=0.2, las=2)
title("marker 5600 (chr2) against chr1")
dev.print(device=pdf, file="graph5600vchr1.pdf")

