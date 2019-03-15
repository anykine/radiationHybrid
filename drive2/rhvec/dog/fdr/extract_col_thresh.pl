#!/usr/bin/perl -w

use strict;
unless (@ARGV==3){
	print <<EOH;
	usage $0 <file to read> <col> <value>
	
	Get all lines in col <col> less than or eq to <value>
EOH
exit(1);
}

my $col = $ARGV[1] - 1;
open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @data = split(/\t/);
	die "col value is greater than # of columns in $ARGV[0]\n" if ($col > scalar @data);
	if ( $data[$col] <= $ARGV[2] ){
		print join("\t",@data), "\n";
	}	
}

