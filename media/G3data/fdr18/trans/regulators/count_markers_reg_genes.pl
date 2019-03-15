#!/usr/bin/perl -w
use strict;

# count the number of genes regulated by each marker
#
unless (@ARGV == 1){
	print "usage $0 <trans_peaksFDR40.txt>\n";
	exit(1);
}

my %markers=();
open(INPUT, "$ARGV[0]") || die "cannot open input\n";
#open(INPUT, "../trans_2.4bymarker1.txt") || die "cannot open input\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	$markers{$line[1]}++;
}

#get position
my @markergc = ();
open(POS, "/home3/rwang/QTL_comp/g3probe_gc_coords.txt") || die "cannot open coords\n";

while(<POS>){
	chomp;
	push @markergc, $_;	
}
close(POS);


#output
foreach my $i (sort {$a<=>$b} keys %markers){
	print "$i\t$markergc[$i-1]\t$markers{$i}\n";
}
