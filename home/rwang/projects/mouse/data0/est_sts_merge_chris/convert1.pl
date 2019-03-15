#!/usr/bin/perl -w

# convert chris' data for database import
#
#
#

use lib '/home/rwang/lib/';
use util;
use strict;

unless (@ARGV){
	print "$0 <file to read>\n";
	exit;
}
my @data = get_file_data($ARGV[0]);

for (my $i=1; $i<=$#data; $i++){
	my($id, $name, $chrom, $chromStart, $chromEnd, $chr, $alias, $genotype);
	($id, $name, $chrom, $chromStart, $chromEnd, $chr, $alias, $genotype)=  split(/\t/, $data[$i]);
#	print "$id\n";
#	print "$name\n";
#	print "$chrom\n";
#	print "$chromStart\n";
#	print "$chromEnd\n";
#	print "$alias\n";
#	print "$genotype\n";

	$id =~ s/"//g;
	$name =~ s/"//g;
	$chrom =~ s/"//g;
	$chrom =~ s/chr//g;
	$chr =~ s/"//g;
	$alias =~ s/"//g;
	$genotype =~ s/"//g;
	$genotype =~ s/ //g;
	$genotype =~ s/-/0/g;
	$genotype =~ s/\?/2/g;

	print "$id\t$name\t$chrom\t$chromStart\t$chromEnd\t$chr\t$alias\t$genotype";	
	
	}
