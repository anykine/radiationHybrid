#2/29/08
# quantile normalization of G3 RH data

library(beadarray)
dataFile = "../phase1/080226_g3_AandB,A23_unorm_separate_gene_profile.txt"
sampleSheet = "ilmn_G3_samplesheet_80cells_62_66correct_modified.csv"
BSData = readBeadSummaryData(dataFile, sampleSheet=sampleSheet, skip=7, columns=list(exprs = "AVG_Signal") )

#normalize
library(affy)
#this does the log10 transform
#BSData = assayDataElementReplace(BSData, "exprs", as.matrix(log10(exprs(BSData))))
BSData.quantile = normaliseIllumina(BSData, method="quantile", transform="log2")
