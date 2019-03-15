#!/usr/bin/perl -w
#
# parse the mouse zero gene peaks ranges file for liftover
use strict;
open(INPUT, "mouse_zero_gene_peaks2_ranges300k_FDR30.txt") || die ;
while(<INPUT>){
	chomp; next if /^#/;
	my @d = split(/\t/);
	#print chrom | start | stop pos
	$d[5]+=60 if ($d[5]-$d[2] == 0);
	print join("\t", $d[1], $d[2], $d[5]),"\n";

}
