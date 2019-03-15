#analysis cis between human and mouse

#data format human idx| human alpha|mus idx|mus alpha

data = read.table("comp_hum_mouse_FDR40.txt")

count11 = sum(data[,2] > 0 & data[,4] > 0)
count10 = sum(data[,2] < 0 & data[,4] > 0)
count01 = sum(data[,2] > 0 & data[,4] < 0)
count00 = sum(data[,2] < 0 & data[,4] < 0)

data.mat = matrix(c(count11, count01, count10, count00), 2, 2)
data.chisq = chisq.test(data.mat)

# pearson correlation
data.cor = cor.test(data[,2], data[,4])

#plot
plot(data[,2], data[,4], pch=".", xlab="human alpha", ylab="mouse alpha", main="human v mouse alpha")
#regression line
data.rl  = lm(data[,4] ~ data[,2])
abline(data.rl)

#mouse neg alpha test
data.mouseneg= chisq.test(data.mat[2, ])

#mouse pos alpha test
data.mousepos = chisq.test(data.mat[1, ])
