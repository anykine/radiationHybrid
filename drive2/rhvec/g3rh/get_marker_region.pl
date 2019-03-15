#!/usr/bin/perl -w

use strict;
unless(@ARGV == 5){
	print <<EOH;
	usage $0 <marker-pval file> <x1> <y1> <x2> <y2>
	eg ./get_marker_region.pl  18577pvals060617.pretty.txt 1104 7698 1109 7703 >extractg3-spot2.txt

	Get the markers in a defined region and output to file. Afterwards, run marker_to_genomecoord.pl. 
EOH
exit(0);
}

my $x1=$ARGV[1];
my $y1=$ARGV[2];
my $x2=$ARGV[3];
my $y2=$ARGV[4];

open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	my @data = split(/\t/);
	if ($data[0] >= $x1 && $data[0]	<=$x2){
		if ($data[1] >= $y1 && $data[1] <=$y2){
			print $_;
		}
	}
}
