#!/usr/bin/perl -w

#calculates primer temperatures for G3 primers
# Input fmt: sts_name, fwd primer, rev primer, chrom, chromStart
# Output fmt: sts_name, fwd primer, rev primer, chrom, chromStart, fwd melttemp, rev melttemp
use strict;
use warnings;
use lib '/home/rwang/lib';
use util;
use melttemp;

my @data = get_file_data("get_primers.out");
#skip the first line of headers
for (my $i=1; $i<=$#data; $i++ ){
	#print "$data[$i]\n";
	my @splits = split(/\t/, $data[$i]);
	my $datastr = $data[$i];
	$datastr =~ s/\n//;
	print $datastr . "\t";
	if ($#splits == 4){
		print melttemp($splits[1]) . "\t";
		print melttemp($splits[2]) . "\n";
	} else {
		print "\n";
	}
}
