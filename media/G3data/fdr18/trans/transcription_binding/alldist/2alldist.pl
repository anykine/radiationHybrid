#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;
use lib '/home/rwang/lib';
use hummarkerpos;

my $INF = 999999999;
# calculate all distance pairs markers/gene pos
# using start positions
# To speed up calc, only calc distance between markers/gene on same chrom
# the use dynamic programming to map markers to genes as per GO emails from Sangtae/Josh
sub calc_alldist{
	load_markerpos_from_db_range("g3data");
	open(INPUT, "ucschg18_miRNA_cleaned_sort.txt") || die "file fail";
	my $curchrom = 1;
	open(OUTPUT, ">diffschr1.txt");
	#iter over all genes
	while(<INPUT>){
		chomp; next if /^#/;
		my ($mchr, $mstart, $mstop, $msym) = split(/\t/);
		#check
		if ($mchr != $curchrom){
			close(OUTPUT);
			$curchrom = $mchr;
			open(OUTPUT, ">diffs".$curchrom.".txt");
		}
		# for all markers on that chrom, calc diff
		for (my $i=0; $i < scalar @{$hummarkerpos{$mchr}{idx}}; $i++){
			print OUTPUT abs($mstart	 - ${$hummarkerpos{$mchr}{start}}[$i]);
			my $len = scalar @{$hummarkerpos{$mchr}{idx}};
			if ($i != $len-1) {
				print OUTPUT "\t";
			} else {
				print OUTPUT "\n";
			}
		}
	}
	close(OUTPUT);
}


########### MAIN ###################
calc_alldist();
