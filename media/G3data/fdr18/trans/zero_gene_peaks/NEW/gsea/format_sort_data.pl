#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

# format the mouse cgh files to be uppercase
# sort the .cghall files


unless (@ARGV ==1 ){
	print "usage $0 <.cghall file>\n";
	print "Sort a .cghall file (symbol|-log p) by nlp and uppercase gene symbol\n";
	exit(1);
}

my %file = ();

#input file: gene | -log pval
open(INPUT, $ARGV[0]) || die "cannot open file";
while(<INPUT>){
	chomp; next if /^#/;
	my ($sym, $nlp) = split(/\t/);
	if (defined $file{$sym}){
		$file{$sym} = $nlp if $nlp > $file{$sym};
	} else {
		$file{$sym} = $nlp;
	}
}

#sort and output
foreach my $k (sort {$file{$b} <=> $file{$a}} keys %file){
	print join("\t", uc($k), $file{$k}),"\n";
}
