# do fisher's on the GMT files
# some gene names in this file have spaces
temp = read.table("/media/G3data/fdr18/trans/transcription_binding/alldist/ucscgenes_FDR40_groups.txt")
fdrout = temp[temp[,1] == "OUT", ]
fdrin  = temp[temp[,1] == "IN", ]


# load a GSEA .GMT file
#borrowed from GSEA code
# cat=category, gocat=bp,cc,mf
loadGeneset = function(gene_set_file){
  temp = readLines(gene_set_file)
  num.genesets = length(temp)
  gs.data = list()
  for (i in 1:num.genesets){
    cat.len = length(unlist(strsplit(temp[[i]], "\t")))
    gs.data$cat = c(gs.data$cat, unlist(strsplit(temp[[i]], "\t"))[1])
    gs.data$gocat = c(gs.data$gocat, unlist(strsplit(temp[[i]], "\t"))[2])    
    gs.data[[paste("m",i,sep="")]] = as.character(unlist(strsplit(temp[[i]],"\t"))[3:cat.len])
    gs.data$size[[paste(i,sep="")]] = length(gs.data[[paste("m", i,sep="")]])
  }
  return(gs.data)
}

# parameters
# gs.data = list of gene sets
# fdrin, fdrout = table of fdrin, fdrout
# minCount = min # of genes in geneset to be considered
calcFisher = function(gs.data, fdrin,fdrout,minCount){
  templen = length(gs.data$cat)
  output = list(cat = gs.data$cat, gocat=gs.data$gocat, size=gs.data$size, count=vector(length=templen, mode="numeric"),pval=vector(length=templen,mode="numeric"))
  for (i in 1:length(gs.data$cat)){
    if (length(gs.data[[paste("m",i,sep="")]]) >= minCount){
      pGOpFDR = sum(is.element(gs.data[[paste("m",i,sep="")]], fdrin[,3]))
      #pGOnFDR = sum(is.element(gs.data[[paste("m",i,sep="")]], fdrout[,3]))
      pGOnFDR = length(gs.data[[paste("m",i,sep="")]])-pGOpFDR
      nGOpFDR = dim(fdrin)[1] - pGOpFDR
      nGOnFDR = dim(fdrout)[1] - pGOnFDR
      #Sangtae used a one sided test, that's why everything is greater
      res = fisher.test(matrix(c(pGOpFDR,pGOnFDR,nGOpFDR,nGOnFDR),2,2), alternative="greater") 
      output$count[i] = pGOpFDR
      output$expected[i] = (pGOpFDR+pGOnFDR)*(pGOpFDR+nGOpFDR)/(pGOpFDR+pGOnFDR+nGOpFDR+nGOnFDR)
      output$pval[i] = res$p.value
    } else {
      output$pval[i] = 1
    }
  }
  output$qval = FDRcalc(output$pval)
  return(output)
}

FDRcalc = function(pvals){
  N = length(pvals)
  # sorted
  index = order(pvals)
  mul = seq(1,N)
  qvals = pvals[index]*N/mul
  for (i in 1:(N-1)){
    qvals[N-i] = min(qvals[N-i], qvals[N-i+1])
  }
  #need to get this back into original order
  return(qvals[order(index)])
}

# write a pretty output file
writeResults = function(fname, data){
  #if (missing(fname)){
  #  fname = paste("result",format(Sys.Date(),"%Y%m%d"), ".txt", sep="")
  #}
  f = file(fname, "w")
  # print GO naxomespace| GO category | pval | count(obs)|expected| size of GO cat
  for (i in 1:length(data$pval)){  
    cat(data$gocat[i],"\t",data$cat[i],"\t",data$pval[i],"\t",data$qval[i],"\t", data$count[i], "\t", data$expected[i],"\t",data$size[i],"\n", file=f)
  }
  close(f)
}

# code to run
# we can run human GoSlim, GSEA GO.gmt, ilmn.gmt, 
res = loadGeneset("/media/G3data/fdr18/trans/transcription_binding/alldist/goslim/human.goslim.gmt")
res = loadGeneset("ilmn_GO.gmt")
res = loadGeneset("human_GOA70.gmt")
res = loadGeneset("human_GOA70_microRNA.gmt")
res = loadGeneset("~/downloads/R/GSEA-P-R/GeneSetDatabases/c3.mir.v2.5.symbols.gmt")
res = loadGeneset("microRNA.gmt")
o = calcFisher(res, fdrin, fdrout,7)


