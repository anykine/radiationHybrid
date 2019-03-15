#!/usr/bin/perl -w

use strict;
unless (@ARGV==2) {
	print <<EOH;
	usage $0 <file to use> <column w/ RefSeqID.version>
	  e.g. $0 ilmn_probe_acc.txt 2
	
	This script removes the version number from the RefseqID
	in the specified column. For example, NM_010101.1 turns 
	into NM_010101. Note that the first column is zero (0) not 1.
EOH
exit(0);
}

open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
#open(OUTPUT, ">$ARGV[0]".".parsed") or die "cannot open file for read\n";
while(<INPUT>) {
	next if /^#/;
	chomp;
	my @data = split(/\t/);
	#print $data[1], "\n";
	$data[$ARGV[1]] =~ s/\.\d$//;
	print join("\t",@data),"\n";
	#print OUTPUT join("\t",@data),"\n";
}
close(INPUT);
close(OUTPUT);
