# normalize CGH data using CGHnormaliter
library(CGHnormaliter)
x = read.table("all.cghnormaliter.sort")
result = CGHnormaliter(x)
normalized.data = copynumber(result)
# this will save normalized data to normalized.txt
CGHnormaliter.write.table(result)
#write.table(normalized.data, file="norm.output")
