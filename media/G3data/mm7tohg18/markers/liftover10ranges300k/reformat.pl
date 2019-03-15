#!/usr/bin/perl -w
#
# take the mouse zero gene ranges file and 
# 1. move line number to end of line
# 2. get rid of leading spaces
# 3. for blocks of length 0, add 60 bases
# for sending to mm7->hg18 liftover

use strict;

# input format: linenum|chrom|start|stop
open(INPUT, $ARGV[0]) || die "cannot open file $ARGV[0] for reformatting";
while(<INPUT>){
	next if /^#/ ; chomp;
	my @d = split(/\t/);
	#output format: chrom|start|stop|linenum
	$d[3]+=60 if ($d[3] - $d[2] == 0);
	print join("\t", $d[1], $d[2], $d[3], $d[0]),"\n";
}
