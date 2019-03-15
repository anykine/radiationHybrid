# plot the frobenius norm null distribution
null = read.table("all_permute.txt")
hist(null[,1]*10, main="SymAtlas RH distance", xlab="F.norm")

dev.print(device=pdf, file="frobenius_symAtlasRH.pdf")
#obs value
rhSym = 2286.854545
abline(v=rhSym/10, col="red")

