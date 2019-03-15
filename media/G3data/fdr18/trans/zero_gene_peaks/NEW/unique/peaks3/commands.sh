# STEP create zero gene blocks from "corrected" zero gene ceQTLs
#../find_zerogene_peaks_merge.pl ../../peaks3/zero_gene_peaks3_ucschg18_FDR10_markersonly.txt > zero_gene_peaks3_FDR10_ranges300k.txt

# STEP compare zero gene3 blocks against ucsc gene desert+microRNA 
# and determine occupancy; need to modify gene desert file in compare_corrected_peak2.pl
prefix=zero_gene_peaks3_FDR
suffix=_ranges300k.txt
newsuffix=_ranges300k_occupancy.txt
#for i in 10 20 30; do 
#	#../compare_corrected_peak2.pl zero_gene_peaks3_FDR30_ranges300k.txt > 
#	../compare_corrected_peak2.pl $prefix$i$suffix > $prefix$i$newsuffix
#done

newnewsuffix=_ranges300k_occupancy_labeled.txt
# STEP need to modify gene desert file in compare_corrected_peak2.pl 
#../add_blocknum2occup.pl h zero_gene_peaks3_FDR20_ranges300k_occupancy.txt
#for i in 10 20 30; do
#	../add_blocknum2occup.pl h $prefix$i$newsuffix > $prefix$i$newnewsuffix
#done;


# STEP get the block number (relative to master gene desert "reference" list
#
for i in 10 20 30; do
	cut -f1 $prefix$i$newnewsuffix | sort -n | uniq > humanFDR${i}blocks.txt
done;
