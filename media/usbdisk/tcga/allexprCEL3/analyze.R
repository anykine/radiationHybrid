options(echo=FALSE)
#bioC code for normalization of expression data
#using RMA

normalizeExpr = function(){
  library(affy)
  setwd("/media/usbdisk/tcga/allexprCEL3/")
  # Quick start ala affy.pdf
  fs = list.files(pattern=".CEL")
  eset = justRMA(filenames = fs)
  #Data = ReadAffy()
  write.exprs(eset, file="all.rma.norm.txt")
}
normalizeExpr()
