# gene list is a file
# gene.set is a file
compare.lists <- function(gene.list.file, gene.set.file){
  
# list of genes regulated by microRNA
#gene.set = read.table("../sanger_target/no5.2col")
gene.set.filename = paste("../sanger_target/", gene.set.file, sep="")
gene.set = read.table(gene.set.filename)
gene.set.unique = unique(gene.set[,2])
gene.set2 = list(nlp = -log10(gene.set[,1]), logp= gene.set[,1], gene=gene.set[,2], unique.gene.names = gene.set.unique)

# all genes for a CGH marker
gene.list.filename = paste("../", gene.list.file, sep="")
#gene.list = read.table("../no5.cghall")
gene.list = read.table(gene.list.filename)

#sort gene.list by nlp (desc) & remove duplicates
gene.list.sort = gene.list[order(-gene.list[,2]), ]
u2 = gene.list.sort[!duplicated(gene.list.sort[,1], fromLast=FALSE),]
gene.list2 = list(unique.gene.names=u2[,1], unique.nlp=u2[,2], unique.sorted=TRUE)

in.list = sign(match(gene.list2$unique.gene.names, gene.set2$unique.gene.names, nomatch=0))
out.list = 1-in.list

len.list = length(gene.list2$unique.gene.names)
len.set  = length(gene.set2$unique.gene.names)
len.diff = len.list-len.set

# this is length of entire gene list
gene.list.mask = rep(1, len.list)
# num genes in gene set found in gene list
sum.in.list = sum(gene.list.mask[in.list==1])

#clever way to get difference of two distributions at every point
result = cumsum(in.list*gene.list.mask*(1/sum.in.list) - out.list*(1/len.diff))
max.result = max(result)
min.result = min(result)
if (max.result > -min.result){
  D = max.result
} else {
  D = min.result
}
in.list.result = in.list*gene.list.mask*(1/sum.in.list)
out.list.result = out.list*(1/len.diff)
par(mfrow=c(1,2))
plot(cumsum(in.list.result), pch=".")
par(new=T)
plot(cumsum(out.list.result), pch=".", col="red")

# plot the difference between two distributions
plot(result, pch=".")
#calculate the KS statistic and get the value from the table
n=len.list*len.set/(len.list+len.set)
pval = 1-pkstwo(sqrt(n) * D)

#        PVAL <- ifelse(alternative == "two.sided", 1 - pkstwo(sqrt(n) * 
#            STATISTIC), exp(-2 * n * STATISTIC^2))
return(pval)
}
    pkstwo <- function(x, tol = 1e-06) {
        if (is.numeric(x)) 
            x <- as.vector(x)
        else stop("argument 'x' must be numeric")
        p <- rep(0, length(x))
        p[is.na(x)] <- NA
        IND <- which(!is.na(x) & (x > 0))
        if (length(IND)) {
            p[IND] <- .C("pkstwo", as.integer(length(x[IND])), 
                p = as.double(x[IND]), as.double(tol), PACKAGE = "stats")$p
        }
        return(p)
    }
