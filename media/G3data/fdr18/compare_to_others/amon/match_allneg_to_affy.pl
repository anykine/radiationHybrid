#!/usr/bin/perl -w
#
# per Des' request, do GO analysis on negative alphas in both mouse
# AND amon data
#
# Need to get affyids for those -/- genes
use strict;

my %gene2affy=();
sub load_affyids{
	open(INPUT, "chr_amon.txt") || die "cannot open file";
	while(<INPUT>){
		chomp;
		# some genes have multiple affyids, but let's just pick one
		my @data = split(/\t/);			
		# gene => affyid
		$gene2affy{$data[2]} = $data[1];
	}
}

####### MAIN ############

load_affyids();
#stream in the list of -/- gene names and get affyids
open(INPUT, "allneg.csv") || die "cannot open neg neg alphas\n";
while(<INPUT>){
	next if /V1,V2/;
	chomp;
	my @data = split(/,/);	
	print $gene2affy{$data[0]},"\n" if defined $gene2affy{$data[0]};
}


