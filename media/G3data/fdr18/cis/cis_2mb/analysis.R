## FDR30 cis
cis30 = read.table("cis_FDR30_annot.txt")
namelst = c("chrom", "start", "stop", "symbol", "index", "marker", "alpha", "nlp")
names(cis30) = namelst
sum(cis30$alpha <0)
sum(cis30$alpha > 0)
hist(cis30$alpha, breaks=500, col="red", xlim=c(-2,2), xlab="alpha", main="Distribution of cis alpha FDR30")

## Compare Human FDR30 w/ Mouse FDR40
comp = read.table("comp_MH_cis_alphas/comp_MH_FDR30.txt")
cor.test(comp[,5], comp[,7])

## Compare Human FDR30 w/ Amon dataset
comp.amon = read.table("/media/G3data/fdr18/compare_to_others/amon/newchr1/human/t")
comp.amon = read.table("/media/G3data/fdr18/compare_to_others/amon/newchr1/human/comp_amon_H_allcis.txt")
comp.amon = read.table("/media/G3data/fdr18/compare_to_others/amon/newchr1/human/comp_amon_H_signifonly.txt")
cor.test(comp.amon


comp.
