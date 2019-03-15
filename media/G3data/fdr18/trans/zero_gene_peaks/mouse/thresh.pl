#!/usr/bin/perl -w
#
# threshold mouse zero-gene eqtls

use strict;

unless (@ARGV==1){
	print "usage $0 <FDRthreshold (30,20,10...)>\n";
	print "threshold mouse 0 gene file on an FDR level\n";
	exit(1);
}
# fdr thresholds from mouse trans breakpoints file
my %fdr=(
	30=>4.6317,
	29=>4.6896,
	28=>4.7480,
	27=>4.8063,
	26=>4.8680,
	25=>4.9305,
	24=>4.9948,
	23=>5.0545,
	22=>5.1168,
	21=>5.1832,
	20=>5.2490,
	10=>6.0088,
	5 =>6.5817,
	1 =>7.7912
);

open(INPUT, "0_gene_300k_trans_4.0.txt") || die "cannot open mouse file";
while(<INPUT>){
	chomp;next if /^#/;
	my @d = split(/\t/);
	print join("\t", @d),"\n" if $d[4] >= $fdr{$ARGV[0]};
}
