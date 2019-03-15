#!/usr/bin/perl -w

use strict;
unless (@ARGV == 1){
	print <<EOH;
	usage: $0 <file to manipulate>

	this program reads a file and adds line numbers to it

	e.g. $0 ./file.txt
EOH
	exit 0;
}

open INPUT, $ARGV[0] or die "cannot open file for read\n";
my $output = $ARGV[0].".num.txt";
print $output;
open OUTPUT, ">$output" or die "cannot open file for write\n";
my $rownum = 1;
while (<INPUT>){
	next if /^#/; #skip comments
	print OUTPUT "$rownum\t$_";
	$rownum++;
}
close INPUT;
close OUTPUT;
