library(qvalue)
p<-scan("qvalue.in")
qobj <- qvalue(p)
qwrite(qobj, filename="qvalue_R_results.txt")
max(qobj$pvalues[qobj$qvalues <= 0.01])

