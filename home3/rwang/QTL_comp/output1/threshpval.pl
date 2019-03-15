#!/usr/bin/perl -w
#
use strict;

unless(@ARGV==2){
	print "usage: $0 <neglogp> <inputfile>\n";
	print " assumes input file is gene|marker|mu|alpha|neglogp\n";
	exit(1);
}

open(INPUT, $ARGV[1]) or "die cannot open input\n";
while(<INPUT>){
	next if /^#/;
	if ((split(/\t/))[4] >= $ARGV[0] ){
		print $_;
	}

}
