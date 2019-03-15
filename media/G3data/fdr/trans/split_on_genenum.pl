#!/usr/bin/perl -w
use strict;

unless (@ARGV==3){
	print "Splits file so that a given gene num is always in the same file.\n";
	print "Handy for splitting up trans QTLs into multiple files.\n";
	print "usage: $0 <file> <gene num to split on> <prefix>\n";
	exit(1);
}
my $genesplit = $ARGV[1];
my $prefix = $ARGV[2];
my $i=1;
open(INPUT, $ARGV[0]) || die "cannot open input\n";
open(OUTPUT, ">$ARGV[2]".$i) || die "cannot open output\n";
while(<INPUT>){

chomp;
my @line = split(/\t/);
if ($line[0] <= $i*$genesplit){
	print OUTPUT join("\t", @line), "\n";
} else {
	close(OUTPUT);
	open(OUTPUT, ">$ARGV[2]".++$i) || die "cannot open output $i\n";
	print OUTPUT join("\t", @line), "\n";
}

}
