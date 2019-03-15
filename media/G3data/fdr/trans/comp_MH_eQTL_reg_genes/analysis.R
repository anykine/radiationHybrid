#quick plot hum v mouse counts of regulating markers per gene

#file format: human idx | hum counts | mouse idx | mouse counts
data = read.table("hum_mus_genecounts_FDR40.txt")

#correlation
data.cor = cor.test(data[,2], data[,4])

data.reg = lm(data[,4] ~ data[,2])

titletext=paste("human v mouse trans # markers regulating genes \n", "r=", data.cor$estimate[[1]])

plot(data[,2], data[,4], pch=".", xlab="human", ylab="mouse", main=titletext)
abline(reg)
