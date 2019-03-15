#!/usr/bin/perl -w
#
use strict;
use lib '/home/rwang/lib';
use g3datamanip;
use Data::Dumper;

unless(@ARGV==2){
	print <<EOH;
	usage $0 <gene> <marker>
	
	get nlp/alp data from file for specified gene/marker pair
EOH
exit(1);
}

my %rec = get_g3record($ARGV[0], $ARGV[1]);

print "gene=$ARGV[0]\tmarker=$ARGV[1]\t";
print "alpha=$rec{alpha}\t nlp=$rec{nlp}\n" 


# testing get all cgh markers for a gene
#my $recref = get_g3records_by_gene($ARGV[0]);
#for (my $i=235815; $i<235829; $i++){
#print "------------\n";
#print $recref->[$i]{gene_id},"\n";
#print $recref->[$i]{marker_id},"\n";
#print $recref->[$i]{alpha},"\n";
#print $recref->[$i]{nlp},"\n";
#}
##print Dumper($recref);
