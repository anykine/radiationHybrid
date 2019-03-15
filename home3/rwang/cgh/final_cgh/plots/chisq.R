# calculate the chi square of PCR markers versus CGH markers
#binned = readLines("binned.txt", header=T, sep="\t")

#crappy R parsing...
binned = readLines("binned.txt")
length = length(binned)-1
names = noquote(unlist(strsplit(binned[1], "\t")))
new = vector(mode="numeric", length=166)
#cells (1/1, 1/0, 0/1, 0/0) of the matrix for chisq
cells = vector(mode="numeric", length=4)

# for every line in file
for (i in 2:length){
  temp = noquote(unlist(strsplit(binned[i],"\t")))
  new = temp[6:171]

  # iter over the array 1..83 and calc chisq
  for(j in 1:83){
    cells[1] = ifelse(new[j] == 1 && new[j+83]==1, addone(cells[1]), cells[1])
    cells[2] = ifelse(new[j] == 0 && new[j+83]==1, addone(cells[2]), cells[2])
    cells[3] = ifelse(new[j] == 1 && new[j+83]==0, addone(cells[3]), cells[3])
    cells[4] = ifelse(new[j] == 0 && new[j+83]==0, addone(cells[4]), cells[4]) 
  }
  #chisq.test(matrix(cells,2,2))
}


addone = function(a){
  a = a+1
  return(a)
}
