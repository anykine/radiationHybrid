# count the unique reads falling on the gene models ; the nomatch files are 
# mappable reads that fell outside of the Cistematic gene models and not the 
# unmappable of Eland (i.e, the "NM" reads)
python2.5 ../commoncode/geneMrnaCounts.py celegans $1.uniqs.bed $1.uniqs.count $1.nomatch.bed

# calculate a first-pass RPKM to re-weigh the unique reads,
# using 'none' for the splice count
python2.5 ../commoncode/normalizeExpandedExonic.py celegans $1.uniqs.bed $1.uniqs.count none $1.firstpass.rpkm

# recount the unique reads with weights calculated during the first pass
python2.5 ../commoncode/geneMrnaCountsWeighted.py celegans $1.uniqs.bed $1.firstpass.rpkm $1.uniqs.recount

# count splice reads
python2.5 ../commoncode/geneMrnaCounts.py celegans $1.splices.bed $1.splices.count $1.nomatchsplices.bed

# calculate expanded exonic read density
python2.5 ../commoncode/normalizeExpandedExonic.py celegans $1.uniqs.bed $1.uniqs.recount $1.splices.count $1.expanded.rpkm -gidField 0 -maxLength 1.0

# weigh multi-reads
python2.5 ../commoncode/geneMrnaCountsWeighted.py celegans $1.multi.bed $1.expanded.rpkm $1.multi.count

# calculate final exonic read density
python2.5 ../commoncode/normalizeFinalExonic.py celegans $1.uniqs.bed $1.splices.bed $1.multi.bed $1.expanded.rpkm $1.multi.count $1.final.rpkm
