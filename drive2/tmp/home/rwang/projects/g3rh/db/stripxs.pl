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
	$line =~ s/m1=//;
	$line =~ s/m2=//;
	$line =~ s/://;
	print OUTPUT "$line\n\n";
}
close(INPUT);
close(OUTPUT);
