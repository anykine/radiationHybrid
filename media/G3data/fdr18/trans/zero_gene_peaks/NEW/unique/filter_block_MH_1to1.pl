#!/usr/bin/perl -w
#
# "Simulation" files are total number of gene deserts in human,
# corrected for markers >300kb away from start&&end of genes
#
# The mouse <-> human block mapping is not 1:1, so let's filter it
# so there is one mouse block to human block mapping, using the closest distance.
 

use strict;
use Data::Dumper;
use Fcntl qw[ :seek ];

my %data = ();
# it actually doesn't matter if the file is sorted, code doesn't care
#
open(INPUT, "peaks3/blocks_MH3_300k_simulation1based.txt") || die "cannot open file";
#open(INPUT, "blocks_MH_300k_simulation1based_sort.txt") || die "cannot open file";
#open(INPUT, "blocks_MH_300k_simulation1based.txt") || die "cannot open file";
while(<INPUT>){
	chomp;next if /^#/;
	my @d = split(/\t/);
	if (defined $data{$d[1]} ){
		$data{$d[1]} = $d[2] if $d[2] < $data{$d[1]};
	} else {
		$data{$d[1]} = $d[2];
	}
}

seek INPUT, 0, SEEK_SET or die "cannot seek to beginning";

# filter list
while(<INPUT>){
	chomp;next if /^#/;
	my @d = split(/\t/);
	if ($d[2] == $data{$d[1]} && defined $data{$d[1]}){
		print join("\t", @d),"\n";
	}
}
#print Dumper(\%data);
