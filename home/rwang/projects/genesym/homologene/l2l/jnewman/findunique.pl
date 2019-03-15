#!/usr/bin/perl -w

use strict;
use lib '/home/rwang/lib';
use util;
use List::Compare;
use Data::Dumper;

unless(@ARGV == 3){
	print <<EOH;
	usage $0 <file1> <col number> <file2>
	eg. $0 Agil_WG 1 ILMN_WG
	this script finds unique elements in a list. you must specify 
	which column and what file
EOH
exit(0);
}
my $column = $ARGV[1];
my %genes;
my %genes2;
my @file = get_file_data($ARGV[0]);

print "length of file is $#file\n";
foreach my $i (@file){
	next if ($i =~ /^#/);
	my @data = split(/\t/, $i);
	$genes{$data[$column]}++;
}
my @uniq = keys %genes;
print $#uniq;

my @file2 = get_file_data($ARGV[2]);
foreach my $j (@file2){
	next if ($j =~/^#/);
	my @data = split(/\t/, $j);
	$genes2{$data[$column]}++;
}
my @uniq2 = keys %genes2;

my $lc = List::Compare->new(\@uniq, \@uniq2);
my @intersect = $lc->get_intersection;
print Dumper(\@intersect);
print "size of intersect is ", scalar @intersect, "\n";
