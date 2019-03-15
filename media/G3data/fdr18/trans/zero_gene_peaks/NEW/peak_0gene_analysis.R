# diagnostic, see spacing between markers
x = read.table("uniq_markers300k_zerog_pos.txt")

for (i in seq(1,24,1)){
    chr1 = x[,1]==i
    a.avg = (x[chr1,2]+x[chr1,3])/2
    # plot chrom one to see spacing between markers
    title = paste("spacing human 0-gene peaks chr", i, sep="")

    upper = sum(chr1)
    fname = paste("./unique/chr", i, ".pdf", sep="")
    pdf(file=fname, width=8.5, height=11)
    plot(seq(1,upper), a.avg, main=title, xlab="marker index", ylab="base pair")
    dev.off()
      

}
