# count the unique reads falling on the gene models ; the nomatch files are 
# mappable reads that fell outside of the Cistematic gene models and not the 
# unmappable of Eland (i.e, the "NM" reads)
python2.5 ../commoncode/geneMrnaCounts.py $1 $2.uniqs.bed $2.uniqs.count $2.nomatch.bed

# calculate a first-pass RPKM to re-weigh the unique reads,
# using 'none' for the splice count
python2.5 ../commoncode/normalizeExpandedExonic.py $1 $2.uniqs.bed $2.uniqs.count none $2.firstpass.rpkm

# recount the unique reads with weights calculated during the first pass
python2.5 ../commoncode/geneMrnaCountsWeighted.py $1 $2.uniqs.bed $2.firstpass.rpkm $2.uniqs.recount

# count splice reads
python2.5 ../commoncode/geneMrnaCounts.py $1 $2.splices.bed $2.splices.count $2.nomatchsplices.bed

# Alternative 2: use a precomputed list of "new" regions (outside of gene models)
python2.5 ../commoncode/regionCounts.py $3 $2.nomatch.bed $2.newregions.good $2.stillnomatch.bed

# map all candidate regions that are within a given radius of a gene in bp
python2.5 ../commoncode/getallgenes.py $1 $2.newregions.good $2.candidates.txt $4 -trackfar -cache

# calculate expanded exonic read density
python2.5 ../commoncode/normalizeExpandedExonic.py $1 $2.uniqs.bed $2.uniqs.recount $2.splices.count $2.expanded.rpkm $2.candidates.txt $2.accepted.rpkm

# weigh multi-reads
python2.5 ../commoncode/geneMrnaCountsWeighted.py $1 $2.multi.bed $2.expanded.rpkm $2.accepted.rpkm $2.multi.count

# calculate final exonic read density
python2.5 ../commoncode/normalizeFinalExonic.py $1 $2.uniqs.bed $2.splices.bed $2.multi.bed $2.expanded.rpkm $2.multi.count $2.final.rpkm
