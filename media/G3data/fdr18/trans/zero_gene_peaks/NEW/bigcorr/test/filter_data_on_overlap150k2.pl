#!/usr/bin/perl -w
#
# filter data on /media/G3data/fdr18/trans/...NEW/overlap150k.txt
# to see if we can get a comparable distribution of 
# correlation coefficients
#
use strict;
use Data::Dumper;

my %mus2hum=();
my %hum2mus=();

sub load_overlap_filter{
	# mouse marker| hum marker | distance between the two
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/overlap150k.txt") || die "cannot open filter file\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		my @line = split(/\t/);
		$mus2hum{$line[0]} = $line[1];
		$hum2mus{$line[1]} = $line[0];
			
	}
	close(INPUT);
}

###### MAIN ##################
load_overlap_filter();
#my @sortkey = (sort {$a<=>$b} keys %humblocks);
#foreach my $i (@sortkey){
#	print $i,"\n";
#}
##print Dumper(\%humblocks);

# musmarker | hum marker| corr | pval
open(INPUT, "t.overlap150k") || die "cannot open sorted file\n";
while(<INPUT>){
	my @line = split(/\s/);
	# filter by hum marker in overlap file
	if (defined $mus2hum{$line[0]}) {
		print, "\n";
	}
}

