# neg alphas common to hum/mus/amon
common = read.table("common_negalpha_mus_hum_amon.txt")
compMH = read.table("comp_hum_mouse_FDR40_symbol.txt")
compMH = cbind(compMH[,1:4], toupper(compMH[,5]))

# find all the ones that match the common list
idx = which(is.element(compMH[,5], common[,1]) == TRUE)

plot(compMH[,2], compMH[,4], xlim=c(-2,2))
par(new=T)
plot(compMH[idx,2], compMH[idx,4], col="red", xlim=c(-2,2))
