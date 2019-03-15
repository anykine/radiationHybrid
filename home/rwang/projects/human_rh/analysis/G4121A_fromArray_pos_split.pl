#!/usr/bin/perl -w
use strict;
use Data::Dumper;

unless (@ARGV == 1) {
	printf("usage $0 <file to strip>\n");
	exit(1);
}

open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
#skip first line
my %header = ();
my $header = <INPUT>;
chomp($header);
my @header = split(/\t/, $header);
for (my $i=0; $i<=$#header; $i++){
	$header{$header[$i]} = $i;	
}
#print Dumper(\%header);
while(<INPUT>){
	my @data = split(/\t/);	
	next if $data[$header{ProbeName}] !~ /A_\d+_\w+/; 
	next if ($data[$header{GeneName}] eq 'BrightName') || ($data[$header{GeneName}] eq 'BrightCorner');
	print "$data[$header{ProbeName}]\t$data[$header{GeneName}]\t$data[$header{SystematicName}]\n";
}
