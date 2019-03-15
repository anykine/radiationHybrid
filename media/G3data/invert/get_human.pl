#!/usr/bin/perl -w
#
use strict;
use lib '/home/rwang/lib';
use g3datamanipT;
use Data::Dumper;

unless(@ARGV==2){
	print <<EOH;
	usage $0 <gene> <marker>
	
	get nlp/alp data from file for specified gene/marker pair
EOH
exit(1);
}

#my %rec = get_g3recordT($ARGV[0], $ARGV[1]);
#print "gene=$ARGV[0]\tmarker=$ARGV[1]\t";
#print "alpha=$rec{alpha}\t nlp=$rec{nlp}\n" 

#get an array of data for a given CGH marker
my $aref = get_g3records_by_markerT($ARGV[0]);
for (my $i=20990; $i<20996; $i++){
	print "------------------\n";
	print $aref->[$i]{gene_id},"\n";
	print $aref->[$i]{marker_id},"\n";
	print $aref->[$i]{alpha},"\n";
	print $aref->[$i]{nlp},"\n";
}
