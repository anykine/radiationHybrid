#!/usr/bin/perl -w

unless (@ARGV) {
	print "usage: $0 <inputfile>\n";
	exit;
}
open(INPUT, "$ARGV[0]");
open(OUTPUT, ">$ARGV[0]".".out");

while ($line = <INPUT>){
	#print $line;
	if ($line =~ /\t[Cc]hr0/) {
		$line =~ s/[Cc]hr0//;
	} else {
		$line =~ s/[Cc]hr//;
	}
	print OUTPUT $line;
}
