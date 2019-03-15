# plot the cgh versus expr data with regression line
data = read.table("plot_expr_cgh160321_3526.txt")
plot(data[,1], data[,2], pch=".", col="blue", cex=2, xlab = "log10(RH/A23) copy number", ylab= "log10(RH/A23) expression", main="marker 160321 gene 3526")
data.reg = lm(data[,2]~data[,1])
abline(data.reg)
dev.print(device=pdf, file="plot_expr_cgh160321_3526_reg.pdf")

data1 = read.table("plot_expr_cgh209543_8126.txt")
plot(data1[,1], data1[,2], pch=".", col="blue", cex=2, xlab = "log10(RH/A23) copy number", ylab= "log10(RH/A23) expression", main="marker 160321 gene 3526")
data1.reg = lm(data1[,2]~data1[,1])
abline(data1.reg)
dev.print(device=pdf, file="plot_expr_cgh209543_8126_reg.pdf")
