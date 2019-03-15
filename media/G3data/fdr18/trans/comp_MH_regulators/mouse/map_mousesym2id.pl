#!/usr/bin/perl -w
#
# get the gene symbol for the mouse gene ID
use strict;

unless (@ARGV==1){
	print <<EOH;
	usage $0 <mouse file to convert>
	 $0 mouse_regulator_counts.txt
	convert the mouse gene ID to mouse gene symbol
EOH
exit(1);
}

my %sym=();
open(INPUT, "/media/G3data/fdr/cis/comp_MH_cis_alphas/mouse_genesym.txt") or die "cannot open db\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	$sym{$line[0]} = $line[1];
}
close(INPUT);

# file to convert
open(FILE, $ARGV[0]) or die "cannot open input file\n";
while(<FILE>){
	chomp;
	my @line = split(/\t/);
	print "$line[0]\t$sym{$line[0]}\t$line[1]\n";
}
