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
sub read_filter_set_mouse{
	my $file;
	my %data = ();
	$file = '/media/G3data/fdr18/trans/zero_gene_peaks/mouse/simulation/mouse_zero_gene_cgh_markers.txt';
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
my $hashref = read_filter_set_mouse();
my %filestruct=(
	gene => 1,
	marker=>2
);
filter_file("0_gene_300k_trans_4.0.txt", $hashref, \%filestruct);
