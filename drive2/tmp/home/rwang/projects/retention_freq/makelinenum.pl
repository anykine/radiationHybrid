#!/usr/bin/perl -w
# put the line numbers on a file
open (INPUT, "tmpout.sql");
open (OUTPUT, ">markerlines.sql");
while (<INPUT>) {
	($a, $b) = split(/\t/, $_);
	print OUTPUT "$. $a\n" 

}
close (OUTPUT);
close (INPUT);
