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

# get ONLY the markers that are >300kb away from known genes
sub filter_data_on_ranges{
	#this file is also in zerogenepeaks/NEW/bigcorr/bymarker/bymarker/mus_hum_marker_ortholog_alphas.txt
	open(INPUT, "/home/rwang/tut/bin/g3dataaccess/split/test.3.sort") || die "cannot open sorted file\n";
	while(<INPUT>){
		my @line = split(/\s/);
		if (defined $humblocks{$line[1]}) {
			print, "\n";
		}
	}
}

# get the markers that are within known genes
# use the blocks data and whatever is NOT in a block is
# in a gene-ful area
sub filter_data_on_genes{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/bigcorr/bymarker/mus_hum_marker_ortholog_alphas.txt") || die "cannot open file\n";
	while(<INPUT>){
		my @line = split(/\s/);
		if (defined $humblocks{$line[1]}){
			#do nothing
		} else {
			print ,"\n";
		}
	}
}

###### MAIN ##################
load_ranges();
#filter_data_on_ranges();
filter_data_on_genes();
