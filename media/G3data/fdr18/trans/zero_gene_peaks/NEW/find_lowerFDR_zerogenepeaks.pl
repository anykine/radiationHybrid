#!/usr/bin/perl -w
#
# Subset the FDR 40% zero gene eqtls to 30%/20/10
# by using the trans_peaks_FDRnn.txt files as a shortcut.
#
use strict;
use Data::Dumper;

# if marker exists in %zgmarkers and in zero_gene_peaks_ucschg18 file
# it must be a zero gene marker at FDR of hash.
# input file format: gene|marker|alpha|nlp
sub subset_FDR40file{
	my($threshFDR,$href) = @_;
	#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks_ucschg18.txt")
	#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks2_ucschg18.txt")
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/peaks3/zero_gene_peaks3_ucschg18.txt")
		|| die "cannot open zero gene file";
	while(<INPUT>){
		next if /^#/; chomp;
		my @data = split(/\t/);
		if (defined $href->{$data[1]} ){
			print join("\t", @data),"\n";
		}
	}
}

#create a hash: what markers are peaks at FDR30/20/10? 
# input file format: gene|marker|alpha|nlp
sub makeFDRhash{
	my($threshFDR) = shift;
	my %fdrmarkers=();
	open(INPUT, "/media/G3data/fdr18/trans/trans_peaks_FDR".$threshFDR.".txt") 
		|| die "cannot open trans peaks FDR $threshFDR file";
	while(<INPUT>){
		next if /^#/; chomp;
		my @data = split(/\t/);
		$fdrmarkers{$data[1]} = 1;
	}
	return \%fdrmarkers;
}


######### MAIN ######################################## 
unless (@ARGV==1){
	print "usage $0 <fdr>\n";
	exit(1);
}
# subset the 40% FDR to get zero gene peaks at FDR30
#my $href = makeFDRhash(30);
#subset_FDR40file(30,$href);

# subset the 40% FDR to get zero gene peaks at FDR20
#my $href = makeFDRhash("05");
#subset_FDR40file("05",$href);

my $href = makeFDRhash($ARGV[0]);
subset_FDR40file($ARGV[0],$href);
