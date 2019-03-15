#!/usr/bin/sh
#too many trans, so i broke trans into 4 files and called
#find_peaks_and_cis on each part separately
perl trans_markers_reg_gene.pl 0 60000 > rwpart1
perl trans_markers_reg_gene.pl 60000 120000 > rwpart2
perl trans_markers_reg_gene.pl 120000 180000 > rwpart3
perl trans_markers_reg_gene.pl 180000 235830 > rwpart4
