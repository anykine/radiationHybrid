#!/usr/bin/perl -w
#
#
#add gene number to fasta files to make life easier
#ie > gene 1 NM_0101010 descritpion

use strict;
use Data::Dumper;

# get list of files
open(INPUT, "dir.txt") || die "cannot open file\n";
my @list = <INPUT>;
close INPUT;

#hash of data: map gene number to refseq
my %refseq=();
open(INPUT, "table.sql") || die "cannot open table\n";
while(<INPUT>){
	my @line = split(/\t/);
	my $char = '.';
	my $frag = substr $line[2], 0, index($line[2], $char);
	push @{$refseq{$frag}}, $line[0];
}
#print Dumper(\%refseq);
close INPUT;

foreach my $i(@list){
	chomp $i;	
	my $fname = $i;
	chomp($fname);
	$fname =~ s/seq//;
	$fname =~ s/\.fa//;
	#print $fname,"\n";	
	local $/;
	open(INPUT, $i) || die "cannot open file $i\n";
	open(OUTPUT, ">new/$i") || die "cannot open file $i\n";
	my $content = <INPUT>;
	$content =~ s/>/>$fname /;
	print OUTPUT $content;
	close(INPUT);
	close(OUTPUT);
}

