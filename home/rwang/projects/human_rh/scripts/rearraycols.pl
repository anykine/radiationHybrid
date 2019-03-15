#!/usr/bin/perl -w
# used to rearrange columns of R output
# for microarray expression data
# reading in "normalize data order of arys to hybrids" file
#  if a microarray is not included in final order, it will
#  have a value of "drop"

use strict;

my %dictionary=();
# open normalize order of arrays to hybrids file
open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	next if /^#/;
	my @order = split(/,/);
	#create hash map hash{final_order} = original_order
	# start from 0, not 1
	$dictionary{$order[1]-1} = $order[3] if $order[1] ne "drop";
}

#while (my($key,$val ) = each (%dictionary) ) {
#	print "$key = $val\n";
#}

my @output = (); #holds the final formatted data
#open data file
open(INPUT, $ARGV[1]) or die "cannot open file\n";
my $outfile = "$ARGV[1]" . ".out";
open(OUTPUT, ">$outfile") or die "cannot open file for write $!\n";
while(<INPUT>){
	#skip header line
	next if /^"AVG_/;
	#assign each line to orig expression data to array
	chomp;
	#reorder elements according to hash above
	# expression data row0 is name, row1 = rh1,...
	my @data = split(/,/);
	for (my $i=0; $i<=78; $i++) {
		my $index_to_use = $dictionary{$i} ;
		$output[$i] = $data[$index_to_use];	
	}
	#write out
	#print "@output","\n";
	my $line = join(",", @output);
	print OUTPUT "$line\n";
}
