#create plot of cis-trans breakpoints
# fdr40, 30, 20, 10, 5 1
transfdr = c(40, 30, 20, 10, 5)
transnlp = c(2.41, 3.2, 5.84, 7.49, 8.47)
htranspeaks = c(153400, 56538, 952, 65, 20)

cisnlp = c(0.75, 0.93, 1.17, 1.55, 1.92)
hcispeaks = c(17676, 16983, 15311, 12136, 9594)

#plot(transfdr, htranspeaks, type="b", pch=1, yaxt="n")
#axis(side=3, at=transfdr, labels=transfdr)
plot(transfdr, hcispeaks, type="b", pch=2, col="red", xaxt="n", yaxt="n", ylab="")

#rescaling code:
#https://stat.ethz.ch/pipermail/r-help/2000-September/008182.html
#rescale trans data to fit cis axis
scaletrans = (htranspeaks-min(htranspeaks))/(max(htranspeaks)-min(htranspeaks))
scaletrans = scaletrans*(max(hcispeaks) - min(hcispeaks)) + min(hcispeaks)
#points(transfdr, scaletrans)
lines(transfdr, scaletrans, type="b")

#rescale labels positions
#axis(side=2, at=hcispeaks, labels=hcispeaks)
labs = round(seq(min(hcispeaks), max(hcispeaks), length=8), 0)
translabs = (labs - min(hcispeaks))/(max(hcispeaks)-min(hcispeaks))
translabs = translabs * (max(htranspeaks) - min(htranspeaks)) + min(htranspeaks)
translabs = round(translabs,0)
axis(side=2, at=labs, labels=labs)
axis(side=4, at=labs, labels=translabs)
axis(1)
mtext("Counts (cis)", side=2, line=2)
mtext("Counts(trans)", side=4, line = 2)

dev.print(device=pdf, file="cis_trans_breakpoints.pdf")
