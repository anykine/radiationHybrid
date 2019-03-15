#!/usr/bin/perl -w
#
# threshold a column of file with value great than X
use strict;

unless (@ARGV==3){
	print "$0 <file> <column to thresh> <value greater than>\n";
	exit(1);
}

open(INPUT, $ARGV[0]) || die "cannot open file $!";
while(<INPUT>){
	chomp;
	next if /^#/;
	my @d = split(/\t/);
	# column is 1-based, array is 0-based
	print join("\t", @d),"\n" if $d[$ARGV[1]-1] >= $ARGV[2];
}
