#!/usr/bin/perl -w
#
#extract the probe, gene symbol, position from affy annotaiton file
use strict;
my @header=();

open(INPUT, "HT_HG-U133A.na29.annot.csv") || die "err";
while(<INPUT>){
	next if /^#/;
	if ( /"Probe/){
		@header = split(/","/);		
		#output_header(@header);
	}
	my @data= split(/","/); 
	$data[0] =~ s/"//ig;
	$data[14] =~ s/"//ig;

	print $data[0],"\t" , $data[14],"\n";
}

sub output_header{
	my @header = @_;
	for (my $i=0; $i< $#header; $i++){
		print $i, "\t", $header[$i], "\n";
	}
}
