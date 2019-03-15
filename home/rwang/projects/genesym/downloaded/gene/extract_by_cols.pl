#!/usr/bin/perl -w
use strict;
unless (@ARGV == 2) {
	print <<EOH;
	usage: $0 <file> <comma separated list of cols to extract>
	  e.g. $0 gene_info.txt.9606 0,1,2,3 

	Extracts given columns from a tab-delim file. First column is zero, not 1, so
	use $0 <file> 0,1,2 to get the first three columns.
EOH
exit(0);
}

open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
my @cols = split(",",$ARGV[1]);
while(<INPUT>){
	next if /^#/;
	chomp;
	my @data = split(/\t/);
	my @dataout = map{$data[$_] } @cols;
	print join("\t",@dataout),"\n";
}
