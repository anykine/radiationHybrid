# Alternative 2: use a precomputed list of "new" regions (outside of gene models)
python2.5 ../commoncode/regionCounts.py $3 $2.nomatch.bed $2.newregions.good $2.stillnomatch.bed

# map all candidate regions that are within a radius of a gene in bp
python2.5 ../commoncode/getallgenes.py $1 $2.newregions.good $2.candidates.txt $4 -trackfar -cache

# calculate expanded exonic read density
python2.5 ../commoncode/normalizeExpandedExonic.py $1 $2.uniqs.bed $2.uniqs.recount $2.splices.count $2.expanded.rpkm $2.candidates.txt $2.accepted.rpkm -cache

# weigh multi-reads
python2.5 ../commoncode/geneMrnaCountsWeighted.py $1 $2.multi.bed $2.expanded.rpkm $2.accepted.rpkm $2.multi.count -cache

# calculate final exonic read density
python2.5 ../commoncode/normalizeFinalExonic.py $1 $2.uniqs.bed $2.splices.bed $2.multi.bed $2.expanded.rpkm $2.multi.count $2.final.rpkm
