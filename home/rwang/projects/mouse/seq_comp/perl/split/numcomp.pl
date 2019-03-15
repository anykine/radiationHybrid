#!/usr/bin/perl -w
# 
# how many gb records have "complete" in annotation? 

use strict;
our $count = 0;
unless (@ARGV == 1){
print <<EOF;
usage: $0 <file to read>

this program shows how many records have "complete" in annotation
e.g. $0 hamster_fastainfo.csv 
EOF
exit 0;
}
#loop through file of genbank records & their genes
open INPUT, $ARGV[0] or die "cannot open file\n";
<INPUT>; #skip first line
while (<INPUT>){
	# note: quotes around text; genes may have * after it
	#arr[1] = accession
	#arr[4] = gene
	my @line_data = split(/\t/);
	$count++ if $line_data[5] =~ /complete/i;
	print "$count:$line_data[3]\n" if $line_data[5] =~ /complete/i;
}
print $count, "\n";
