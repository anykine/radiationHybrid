#!/usr/bin/perl -w
# remove the chr from chr1, chr2 in UCSC input file
#use strict;
#
unless (@ARGV) {
	print "$0 <filename>\n";
	exit;
}

#open file
my($fh) = $ARGV[0];
open(INPUT, "$fh") || die "can't open file $fh : $!";
open(OUTPUT, ">$fh".".out") || die "canot open output";
while (<INPUT>)
{
	$matchnum = s/chr//;
	print "$matchnum\n";
	print OUTPUT "$_";
}
close INPUT;

