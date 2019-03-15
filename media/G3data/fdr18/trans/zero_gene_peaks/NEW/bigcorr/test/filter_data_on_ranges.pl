#!/usr/bin/perl -w
#
# Output of all-markers-all-genes correlation between mouse and human
# needs to be filtered to get only markers that are in 0-gene regions
# using zero_gene_peaks_ranges300k.txt
#
use strict;
use Data::Dumper;

my %humblocks=();

sub load_ranges{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt") || die "cannot open file\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		my @line = split(/\t/);
		my $limit = $line[3] - $line[0] + 1;
		for (my $i=0; $i<$limit; $i++){
			# store ever mark from start_block to end_block
			$humblocks{$line[0]+$i} = 1;
		}
	}
	close(INPUT);
}

###### MAIN ##################
load_ranges();
#my @sortkey = (sort {$a<=>$b} keys %humblocks);
#foreach my $i (@sortkey){
#	print $i,"\n";
#}
##print Dumper(\%humblocks);

open(INPUT, "/home/rwang/tut/bin/g3dataaccess/split/test.2.sort") || die "cannot open sorted file\n";
while(<INPUT>){
	my @line = split(/\s/);
	if (defined $humblocks{$line[1]}) {
		print, "\n";
	}
}
