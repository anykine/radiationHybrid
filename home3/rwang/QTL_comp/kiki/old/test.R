cgh = read.table("cgh.txt")
expr = read.table("expr.txt")

dim(cgh)
dim(expr)

numsx = c(1:10)
numsy = c(1:10)

for(i in numsx){
for(j in numsx){ 
x = c(cgh[i,], recursive=TRUE);
y = c(expr[j,], recursive=TRUE);
var = lm(y~x);
name = paste("gene_", i , "_", "marker", j);
print(name);
# get the p-value				
print((summary(var)$coefficients)[2,4])
}
}
