#!/usr/bin/perl -w
#utilit to strip some characters from file

use strict;

unless (@ARGV) {
	print "$0 <filename>\n";
	exit;
}
open(INPUT, $ARGV[0]) || die "cannot open input\n";
open(OUTPUT, ">$ARGV[0]".".txt") || die "cannot open output\n";
while (my $line=<INPUT>) {
	$line =~ s/^idx1=//;
	$line =~ s/idx2=//;
	$line =~ s/prob=//;
	print OUTPUT "$line";
}
close(INPUT);
close(OUTPUT);
