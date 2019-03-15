#!/usr/bin/perl -w
#
# for human
# find which/how many markers are > 300kb away from gene
# 12/8/2008 - made changes to how dist(marker,gene) are calculated
#
use strict;
use lib '/home/rwang/lib';
use humgenepos;
use hummarkerpos;
use Data::Dumper;
my $DEBUG = 0;

# load the positions of human markers
sub load_hum_markers{
	load_markerpos_by_index("g3data");	
	# exposes %hummarkerpos_by_index
}

# load positions of human genes
sub load_hum_genes{
	# use UCSC all known genes (big)
	#load_genepos_from_dbucsc2("ucschg18");
	# use REFSEQs
	#load_genepos_from_dbucsc2_refseq("ucschg18");
	# use REFSEQ plus microRNAs
	#load_genepos_from_dbucsc2_refseq_microRNA("ucschg18");
	# use UCSC allknown genes + microRNA
	load_genepos_from_dbucsc2_microRNA("ucschg18");
	# exposes %humgenepos
}

# test conditions
# -greater than 300kb away from current gene index
# -not contained withini gene start/stop pos
# takes: markerpos, marker chrom, gene index, radius
sub test_radius{
	my($mpos, $mchr, $index, $radius) = @_;
	print "index=$index\n" if $DEBUG;
	#set some vars
	my $genestart = ${$humgenepos{$mchr}{start}}[$index];
	my $genestop =  ${$humgenepos{$mchr}{stop}}[$index];

	print "chr $mchr:$mpos index: $index\n" if $DEBUG;
	# if contained wihtin reject
	if ($mpos >= $genestart && $mpos <= $genestop){
		
		if ($DEBUG){
			print "rejecting $mpos between ";
			print "$genestart and ";
			print "$genestop \n";
		}
		return 0;
	} elsif ( (abs($mpos-$genestart)>=$radius) && 
					(abs($mpos-$genestop)>=$radius) ) {

		return 1;
	}	else {
		if ($DEBUG){
			print "rejecting because: ";
			if (abs($mpos-$genestart) < $radius) {
				print "near start $mpos - $genestart = ", abs($mpos-$genestart), "\n";
			} elsif ( abs($mpos-$genestop) < $radius) {
				print "near stop $mpos - $genestop = ", abs($mpos-$genestop), "\n";
			} else {
				print "unknown\n";
			}
		}
		return 0;
	}
}
sub search{

	#for ea cgh marker, see if its within RADIUS of gene
	foreach my $m (sort {$a<=>$b} keys %hummarkerpos_by_index){
		my $mchr = $hummarkerpos_by_index{$m}{chrom};
		my $mpos = $hummarkerpos_by_index{$m}{pos};

		my $flag=0;
		#iterate over all genes on same chrom
		for (my $i=0; $i< scalar @{$humgenepos{$mchr}{start}}; $i++){
			#if ( test_radius($mpos, $mchr, $i, 300000) ){
			if ( test_radius($mpos, $mchr, $i, 500000) ){
			#if ( (abs($mpos-${$humgenepos{$mchr}{start}}[$i]) > 300000) &&
			#	(abs($mpos-${$humgenepos{$mchr}{stop}}[$i]) > 300000) ){
					$flag=1;
			} else {
					$flag = 0;
					last;
			}
		}
		if ($flag){
			print $m,"\n";
		}
	}
}


######### MAIN ##################
load_hum_markers();
load_hum_genes();
#print Dumper(\%humgenepos);
search();
