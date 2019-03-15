#!/usr/bin/perl -w
#
# Need to create file with closest Mouse->Human zero gene markers
# with -logpvals so I can find the best conserved zero gene ceQTLs
# with best -logpvals for GSEA testing for GO enrichment

use strict;
use Data::Dumper;

# create a mapping of mouse -> human cgh markers
my %mus2hum=();
open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/mus2human_closest.txt") || die "err: mus2human_closest.txt";
while(<INPUT>){
	chomp;next if /^#/;
	my @d = split(/\t/);
	$mus2hum{$d[3]} = $d[5];
}
close(INPUT);


#filter this list through mouse zero gene markers,
#retain only pairs with mouse zero gene

my %musfilter=();
open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/mouse/uniq_markers300k_zerog.txt") || die "err uniq mouse zero gene cgh";
while(<INPUT>){
	chomp; next if /^#/;
	$musfilter{$_} = 1;
}
close(INPUT);
foreach my $k (sort keys %mus2hum){
	# if the mouse key is in the mouse hash, do nothing, else delete
	if (defined $musfilter{$k}){
	} else {
		delete $mus2hum{$k};
	}
}

# filter through human zero gene markers,
# retain only pairs with human zero gene
my %humfilter=();
#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks2_ucschg18.txt") || die "cannot open human zero gene";
open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/peaks3/zero_gene_peaks3_ucschg18.txt") || die "cannot open human zero gene";
while(<INPUT>){
	chomp;next if /^#/;
	my @d = split(/\t/);
	$humfilter{$d[1]} = 1;
}
close(INPUT);
foreach my $k (sort keys %mus2hum){
	# if the mouse key is in the mouse hash, do nothing, else delete
	if (defined $humfilter{$mus2hum{$k}}){
	} else {
		delete $mus2hum{$k};
	}
}

#now go build list
# mouse marker | nlp | human marker | nlp


#store hum pval
my %humpval = ();
#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks2_ucschg18.txt") || die "cannot open hum zero gene pvals";
open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/peaks3/zero_gene_peaks3_ucschg18.txt") || die "cannot open human zero gene";
while(<INPUT>){
	chomp; next if /^#/;
	my @d = split(/\t/);
	if (defined $humpval{$d[1]}){
		$humpval{$d[1]} = $d[3] if $humpval{$d[1]} < $d[3];
	} else {
		$humpval{$d[1]} = $d[3];
	}
}


#store mus pval
my %muspval = ();
open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/0_gene_300k_trans_4.0.txt") || die "cannot open mouse pval";
while(<INPUT>){
	chomp; next if /^#/;
	my @d = split(/\t/);
	if (defined $muspval{$d[2]}){
		$muspval{$d[2]} = $d[4] if $muspval{$d[2]} < $d[4];
	} else {
		$muspval{$d[2]} = $d[4];
	}
}

# finally, build the friggin file
foreach my $k (sort {$a<=>$b} keys %mus2hum){
	if (defined $muspval{$k} && defined $humpval{$mus2hum{$k}}){
		print join("\t", $k, $muspval{$k}, $mus2hum{$k}, $humpval{$mus2hum{$k}}),"\n";
	}
}
