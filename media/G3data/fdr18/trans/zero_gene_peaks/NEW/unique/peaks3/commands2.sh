# STEP create zero gene blocks from "corrected" zero gene ceQTLs
#prefix=zero_gene_peaks3_ucschg18_FDR
#suffix=_markersonly.txt
#newprefix=zero_gene_peaks3_FDR
#newsuffix=_ranges300k.txt
#for i in `seq 21 29`; do
##../find_zerogene_peaks_merge.pl ../../peaks3/zero_gene_peaks3_ucschg18_FDR10_markersonly.txt > zero_gene_peaks3_FDR10_ranges300k.txt
#	../find_zerogene_peaks_merge.pl ../../peaks3/$prefix$i$suffix > $newprefix$i$newsuffix
#done

# STEP compare zero gene3 blocks against ucsc gene desert+microRNA 
# and determine occupancy; need to modify gene desert file in compare_corrected_peak2.pl
prefix=zero_gene_peaks3_FDR
suffix=_ranges300k.txt
newsuffix=_ranges300k_occupancy.txt
#for i in `seq 21 29`; do 
##	#../compare_corrected_peak2.pl zero_gene_peaks3_FDR30_ranges300k.txt > 
#	../compare_corrected_peak2.pl $prefix$i$suffix > $prefix$i$newsuffix
#done

newnewsuffix=_ranges300k_occupancy_labeled.txt
# STEP need to modify gene desert file in compare_corrected_peak2.pl 
#../add_blocknum2occup.pl h zero_gene_peaks3_FDR20_ranges300k_occupancy.txt
#for i in `seq 21 29`; do
#	../add_blocknum2occup.pl h $prefix$i$newsuffix > $prefix$i$newnewsuffix
#done;


# STEP get the block number (relative to master gene desert "reference" list
#
for i in `seq 21 29`; do
	cut -f1 $prefix$i$newnewsuffix | sort -n | uniq > humanFDR${i}blocks.txt
done;
