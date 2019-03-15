# normalize CGH data using CGHnormaliter
library(CGHnormaliter)
#x = read.table("test.in")
x = read.table("test.y1")
result = CGHnormaliter(x)
normalized.data = copynumber(result)
# this will save normalized data to normalized.txt
CGHnormaliter.write.table(result)
#write.table(normalized.data, file="norm.output")
