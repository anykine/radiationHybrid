library(LPE)
set.seed(0)

#AllTrisomy tests
var.wt<-baseOlig.error(bretAllEset[,2:10], q= 0.01)
var.ts<-baseOlig.error(bretAllEset[,11:19], q= 0.01)
lpe.val<-data.frame(lpe(bretAllEset[,11:19], bretAllEset[,2:10], var.ts, var.wt, probe.set.name = bretAllEset$ProbeID))
lpe.val<-round(lpe.val, digits = 2)
fdr.BH<-fdr.adjust(lpe.val, adjp = "BH")
write.table(lpe.val, quote = FALSE, sep = "\t", file="tsVwtlpeval.out")
write.table(fdr.BH, quote = FALSE, sep = "\t", file="tsVwtBH.out")

#Ts13 tests
var.wt<-baseOlig.error(bretAllEset[,2:10], q= 0.01)
var.ts13<-baseOlig.error(bretAllEset[,12:15], q= 0.01)
ts13lpe.val<-data.frame(lpe(bretAllEset[,12:15], bretAllEset[,2:10], var.ts13, var.wt, probe.set.name = bretAllEset$ProbeID))
ts13lpe.val<-round(ts13lpe.val, digits = 2)
ts13fdr.BH<-fdr.adjust(ts13lpe.val, adjp = "BH")
write.table(ts13lpe.val, quote = FALSE, sep = "\t", file="ts13Vwtlpeval.out")
write.table(ts13fdr.BH, quote = FALSE, sep = "\t", file="ts13VwtBH.out")

#Ts16 tests
var.wt<-baseOlig.error(bretAllEset[,2:10], q= 0.01)
var.ts16<-baseOlig.error(bretAllEset[,16:18], q= 0.01)
ts16lpe.val<-data.frame(lpe(bretAllEset[,16:18], bretAllEset[,2:10], var.ts16, var.wt, probe.set.name = bretAllEset$ProbeID))
ts16lpe.val<-round(ts16lpe.val, digits = 2)
ts16fdr.BH<-fdr.adjust(ts16lpe.val, adjp = "BH")
write.table(ts16lpe.val, quote = FALSE, sep = "\t", file="ts16Vwtlpeval.out")
write.table(ts16fdr.BH, quote = FALSE, sep = "\t", file="ts16VwtBH.out")


