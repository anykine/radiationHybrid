#!/usr/bin/perl -w

use strict;
unless (@ARGV==3){
	print <<EOH;
	usage $0 <file to read> <pval thresh> <col>

	count the number of lines that are below thresh
EOH
exit(1);
}

my $counter;
my $col = $ARGV[2] - 1;
open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @a = split(/\t/);
	$counter++ if $a[$col] < $ARGV[1];
}
print "$counter below threshold of $ARGV[1]";
