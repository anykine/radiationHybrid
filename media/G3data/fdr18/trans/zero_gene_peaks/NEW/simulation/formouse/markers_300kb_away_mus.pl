#!/usr/bin/perl -w
#
# for mouse 
# find which/how many markers are > 300kb away from gene
# 12/8/2008 - made changes to how dist(marker,gene) are calculated
#
use strict;
use lib '/home/rwang/lib';
use t31genepos;
use t31markerpos;
use Data::Dumper;
my $DEBUG = 0;

# load the positions of mouse markers
sub load_mus_markers{
	load_markerpos_by_index("mouse_rhdb");	
	# exposes %t31markerpos_by_index
}

# load positions of human genes
sub load_mus_genes{
	# use REFSEQ plus microRNAs
	load_genepos_from_dbucsc2_refseq_microRNA("ucscmm7");
	# exposes %t31genepos
}

# test conditions
# -greater than 300kb away from current gene index
# -not contained withini gene start/stop pos
# takes: markerpos, marker chrom, gene index, radius
sub test_radius{
	my($mpos, $mchr, $index, $radius) = @_;
	print "index=$index\n" if $DEBUG;
	#set some vars
	my $genestart = ${$t31genepos{$mchr}{start}}[$index];
	my $genestop =  ${$t31genepos{$mchr}{stop}}[$index];

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
	foreach my $m (sort {$a<=>$b} keys %t31markerpos_by_index){
		my $mchr = $t31markerpos_by_index{$m}{chrom};
		my $mpos = $t31markerpos_by_index{$m}{pos};

		my $flag=0;
		#iterate over all genes on same chrom
		for (my $i=0; $i< scalar @{$t31genepos{$mchr}{start}}; $i++){
			if ( test_radius($mpos, $mchr, $i, 300000) ){
			#if ( (abs($mpos-${$t31genepos{$mchr}{start}}[$i]) > 300000) &&
			#	(abs($mpos-${$t31genepos{$mchr}{stop}}[$i]) > 300000) ){
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
load_mus_markers();
load_mus_genes();
#print Dumper(\%t31genepos);
search();
