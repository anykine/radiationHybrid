#!/usr/bin/perl -w
#
# Criterion of >300kb away from known gene has been done serveral
# ways: >300kb from center of gene or >300kb from begin&&end of gene.
#
# To create a strict set of >300kb away (from start&&end) of gene,
# use the list of markers known to be >300kb from start/end
# in /media/G3data/fdr18/trans/zero_gene_peaks/NEW/simulation
# There two files: markers>300kb from refseq and UCSC genes.
#
# Use this to correct a list of zero gene cgh peaks to remove
# markers that really ARE NOT >300kb away from start&&end of gene
use strict;
use Data::Dumper;

# read in list of certified zero gene cgh markers
# pass in refseq or ucsc 
sub read_filter_set_human{
	my($set) = @_;
	my $file;
	my %data = ();
	if ($set eq 'refseq') {
		$file = '/media/G3data/fdr18/trans/zero_gene_peaks/NEW/simulation/zerocgh_refseq.txt';
	} elsif ($set eq 'ucsc'){
		$file = '/media/G3data/fdr18/trans/zero_gene_peaks/NEW/simulation/zero_gene_cgh.txt';
	} elsif ($set eq 'ucscmiRNA'){
		$file = '/media/G3data/fdr18/trans/zero_gene_peaks/NEW/simulation/zero_gene_cgh_ucsc+miRNA.txt';
	} else {
		return -1;
	}
	open(INPUT, $file) || die "cannot open zero gene marker list";	
	while(<INPUT>){
		next if /^#/; chomp;
		$data{$_} = 1;
	}
	return \%data;
}

# general routine to filter a file
# pass an hashref indicating which column is the marker column
sub filter_file{
	my($file, $filterlist, $filestruct) = @_;
	open(INPUT, $file) || die "cannot open $file";
	while(<INPUT>){
		next if /^#/; chomp;
		my @d = split(/\t/);
		my $marker = $d[$filestruct->{marker} ];
		if (defined $filterlist->{$marker}){
			print join("\t", @d), "\n";
		}
	}
}
########### MAIN  ###################
my $hashref = read_filter_set_human('ucscmiRNA');
my %filestruct=(
	gene => 0,
	marker=>1
);
filter_file("zero_gene_peaks_ucschg18.txt", $hashref, \%filestruct);
