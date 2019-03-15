#G3 take datasetA and B, log, then average
#do same for A23s

a23 = read.table("expr_setA23.txt", header=T)

gen.cormat <- function(){
	#create null matrix
	m = matrix(0, 15,15)
	for (i in 1:15){
		for (j in i:15){
			m[i,j] = cor.test(a23[,i], a23[,j])$estimate
		}
	}
	#output cormat
	m
}

logavg.a23 <-function(){
	#some a23's look better than others
	#a23.log10 = log10(a23)		
	a23.log10 = log10(a23[,8:15])		
	a23.avg = apply(a23.log10, 1, mean)
}

logavg.rhsets <-function(){
	setA = read.table("expr_setA.txt", header=T)	
	setB = read.table("expr_setB.txt", header=T)	
	setA.log10 = log10(setA)
	setB.log10 = log10(setB)
	setavg = (setA.log10 + setB.log10)/2
}

ratio.rhbyham <-function(mat,divisor) {
	#should check that mat is a matrix and divisor is a vector
	res = apply(mat, 2, '/', divisor)
}

##### second try
method2 <- function(){
	a23A = a23[,1:7]
	a23B = a23[,8:15]
	a23A.mean = apply(a23A, 1, mean)
	a23B.mean = apply(a23B, 1, mean)
	
	setA = read.table("expr_setA.txt", header=T)
	setB = read.table("expr_setB.txt", header=T)
	
	setAratio = apply(setA,2,'/', a23A.mean)
	setBratio = apply(setB,2,'/', a23B.mean)
	
	setABratio = (setAratio = setBratio)/2
	logABratio = log10(setABratio)
	return(logABratio)
}
#### third try
method3 <- function() {
	setA = read.table("expr_setA.txt", header=T)
	setB = read.table("expr_setB.txt", header=T)
	
	ABavg = (setA+setB)/2
	A23avg = apply(a23, 1, mean)
	setABratio = apply(ABavg, 2, '/', A23avg)
	logsetABratio = log10(setABratio)
	return(logsetABratio)
}
