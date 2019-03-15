#!/usr/bin/perl -w

#from SQL table of pvals, remove
# markers that are too close to each other
# ie. within 10 markers
use strict;
use lib '/home/rwang/lib/';
use util;

unless (@ARGV) {
	print "$0 <input filename>\n";
	exit;
}
my $outfile = "$ARGV[0]". ".out";
open(OUTPUT, ">$outfile");
my @myfile = get_file_data($ARGV[0]);

#skip the header line
for (my $i=1; $i<=$#myfile; $i++){
	my @line = split(/\t/, $myfile[$i]);
	if ($line[1] > $line[0]+11) {
		print OUTPUT "$line[0]\t$line[1]\t$line[2]";
	}
}
