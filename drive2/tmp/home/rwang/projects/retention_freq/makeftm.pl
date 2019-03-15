#!/usr/bin/perl -w
# beat the datafile into shape
# create data file from radiation hybrid vectors
# count num of times marker present/absent in each cell line

use lib '/home/rwang/lib/';
use strict;
use util;

unless($ARGV[0]) {
	print "usage $0 <rhvector file>\n";
	exit;
}

my @raw = get_file_data($ARGV[0]);
#for (my $i=0; $i<$#raw ; $i++) {
	#my $vec = $raw[$i];
	my $vec = $raw[0];
	#count 'em: 0=absent,1=present,2=unknown
	my $present = ($vec =~ tr/1//); 
	my $absent =  ($vec =~ tr/0//); 
	my $unknown = ($vec =~ tr/2//) ;

print "present=$present\tabsent=$absent\tunknown=$unknown\n";
print "$vec\n"; 
#}
