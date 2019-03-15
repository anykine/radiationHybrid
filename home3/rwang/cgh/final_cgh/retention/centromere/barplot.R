# create the barplot of centromeric versus noncentromeric retention frequency
d = readLines("forR.txt")
num.lines = length(d)

data = list()

means = vector(length=48, mode="numeric")
sds = vector(length=48, mode="numeric")
labels = vector(length=48, mode="character")
sem = vector(length=48, mode="numeric")

# cut up each line and store in list
# odd numbers are centromeric
# even numbers are noncentromeric
for (i in 1:num.lines){
  suffix = ifelse(i%%2 == 0, "noncent", "cent")
  temp = noquote(unlist(strsplit(d[i], "\t")))  
  data[[ paste(temp[1], suffix, sep="") ]] = temp[-1]
  means[i] = mean(as.numeric(temp[-1]))
  sds[i] = sd(as.numeric(temp[-1]))
  sem[i] = sds[i]/sqrt(length(temp)-1)
  labels[i] = paste(temp[1], suffix, sep="")
}

# bar plots
#https://stat.ethz.ch/pipermail/r-help/2007-October/143937.html
CI.plot = function(mean, std, ylim=c(0, max(CI.H)), ...){
  CI.H = mean+1.96*std # calculate upper CI
  CI.L = mean-1.96*std # lower CI
  xvals = barplot(mean, ylim=ylim, ...) #plot bars
  arrows(xvals, mean, xvals, CI.H, angle = 90, length=0.01)
  arrows(xvals, mean, xvals, CI.L, angle = 90, length=0.01)
}

# make the plot
CI.plot(means, sem, main="Centromeric and Noncentromeric Retention Frequency", ylab="Retention Frequency", names.arg=labels, las=2, cex.names=0.5)

dev.print(device=pdf, file="centromeric_v_noncentromeric_retention.pdf")


#calc t-test for each centromeric and noncentromeric region
#store results as matrix
res = matrix(rep(0,96),24,4)
for (i in 1:24){
  r = t.test(as.numeric(data[[i*2-1]]), as.numeric(data[[i*2]]))
  res[i,1] = i
  res[i,2] = r$statistic
  res[i,3] = r$parameter
  res[i,4] = r$p.value
}
