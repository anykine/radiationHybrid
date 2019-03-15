#!/usr/bin/perl -w
#
use strict;
use lib '/home/rwang/lib';
use g3datamanipT;
use Data::Dumper;

unless(@ARGV==2){
	print <<EOH;
	usage $0 <marker> <field: alpha|nlp>
	
	get nlp/alp data from file for all genes for a specified CGH marker 
EOH
exit(1);
}

# output arrayref
sub output{
	my ($aref, $field) = @_;
	for (my $i=0; $i< 20996; $i++){
		print $aref->[$i]{$field},"\n";
	}
}

#my %rec = get_g3recordT($ARGV[0], $ARGV[1]);
#print "gene=$ARGV[0]\tmarker=$ARGV[1]\t";
#print "alpha=$rec{alpha}\t nlp=$rec{nlp}\n" 

#get an array of data for a given CGH marker
my $aref = get_g3records_by_markerT($ARGV[0]);
#output($aref, 'alpha');
output($aref, $ARGV[1]);
#for (my $i=20990; $i<20996; $i++){
#	print "------------------\n";
#	print $aref->[$i]{gene_id},"\n";
#	print $aref->[$i]{marker_id},"\n";
#	print $aref->[$i]{alpha},"\n";
#	print $aref->[$i]{nlp},"\n";
#}
