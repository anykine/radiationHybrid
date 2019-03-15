#!/usr/bin/perl -w

use strict ;
unless (@ARGV==2){
	print <<EOH;
	usage $0 <sorted pvalue file> <num of markers>
		e.g. $0 dog_all_pvals_sorted.txt
	
	calc the qvalue for the chisq comparison. file is :
		marker1 marker2 pvalue
	output is :
		marker1 marker2 pvalue qvalue
EOH
exit(1);
}

#for dog, 9775 markers tested
#my $m = 9775*9776/2;
my $m = $ARGV[1]*($ARGV[1]+1)/2;
my $counter=1;
open(INPUT, $ARGV[0]) or die "cannot open file !\n";

while(<INPUT>){
	next if /^#/;
	chomp;
	my @data = split(/\t/);
	my $qval = $data[2]*$m/$counter;
	print join("\t",@data), "\t$qval\n";
	$counter++;
}
close(INPUT);
