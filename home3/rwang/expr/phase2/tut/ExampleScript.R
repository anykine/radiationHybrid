###Code to read the data into R

library(beadarray)

dataFile = "raw_data.csv"
sampleSheet = "raw_data_sample_sheet.csv"
qcFile = "raw_data_qcinfo.csv"

BSData <- readBeadSummaryData(dataFile, qcFile=qcFile, sampleSheet=sampleSheet,skip=7, columns=list(exprs="AVG_Signal", se.exprs="BEAD_STDEV", NoBeads="Avg_NBEADS"), qc.columns=list(exprs="AVG.Signal", se.exprs="SeqVAR"),qc.sep="," ,sep=",", qc.skip=7, annoPkg="illuminaHumanv1")


##Example of how to read and subset the different slots available in BSData

BSData
slotNames(BSData)
names(assayData(BSData))

dim(assayData(BSData)$exprs)
dim(assayData(BSData)$BeadStDev)
dim(assayData(BSData)$Narrays)

exprs(BSData)[1:10,1:2]
se.exprs(BSData)[1:10, 1:2]
pData(BSData)[,c(4,6)]

QCInfo(BSData)$exprs[1:5,1:4]




##Simple boxplots of expression levels and number of each bead type

par(mfrow=c(1,2))
boxplot(log2(exprs(BSData)[1:1000,]),las=2)
boxplot(NoBeads(BSData)[1:1000,], las=2)




##Creating MA and XY plots to compare arrays


g = rownames(exprs(BSData))[1:10]
g
cols = rainbow(start=0, end=5/6, n=10)

plotMAXY(exprs(BSData)[1:1000,], arrays=1:3, genesToLabel=g, labelCols=cols, labels=as.character(pData(BSData)[1:3,4]),pch=16)


##Illumina QC information may be read using readQC. Objects created by readBeadSummaryData should already have this infomation stored.
QC =QCInfo(BSData)

QC$exprs[1:3,]
plot(log2(as.numeric(QC$exprs[1,])), type="l")



##Normalisation can be done using function from the affy library or the Illumina background normalisation can be done


BSData.quantile = assayDataElementReplace(BSData, "exprs",normalize.quantiles(as.matrix(exprs(BSData))))
BSData.qspline = assayDataElementReplace(BSData, "exprs", normalize.qspline(as.matrix(exprs(BSData))))



##For differential expression analysis, the functions from 'limma' can be used on log-transformed values

design=matrix(nrow=18, ncol=6,0)

colnames(design) = c("I", "MC", "MD", "MT", "P", "Norm")

design[which(strtrim(colnames(exprs(BSData)),1)=="I"),1]=1
design[which(strtrim(colnames(exprs(BSData)),2)=="MC"),2]=1
design[which(strtrim(colnames(exprs(BSData)),2)=="MD"),3]=1
design[which(strtrim(colnames(exprs(BSData)),2)=="MT"),4]=1
design[which(strtrim(colnames(exprs(BSData)),1)=="P"),5]=1
design[which(strtrim(colnames(exprs(BSData)),1)=="N"),6]=1

design

fit = lmFit(log2(exprs(BSData)), design)

cont.matrix=makeContrasts(IvsP = I - P, IvsNorm = I-Norm, PvsNorm = P-Norm,levels=design)

fit = contrasts.fit(fit, cont.matrix)

ebFit = eBayes(fit)

topTable(ebFit)



##Simple example of how a clustering can be performed

d =dist(t(exprs(BSData)))

plclust(hclust(d), labels=rownames(pData(BSData)))





##Example of getting data from BiomaRt

library(biomaRt)
ensembl <- useMart("ensembl", dataset="hsapiens_gene_ensembl")
illuids = results$ID

BM <- getBM(attributes=c("illumina_v1", "entrezgene", "go", "go_description"), filters="illumina_v1", values=illuids, mart=ensembl)


BM[1:20,]

