#!/usr/bin/perl -w

use strict ;
unless (@ARGV==1){
	print <<EOH;
	usage $0 <sorted pvalue file> <num of markers>
		e.g. $0 dog_all_pvals_sorted.txt <num of lines in file>
	
	repurposed for chris' trans/cis data which is negative log pvalue instead of pval
	calc the qvalue for the chisq comparison. file is :
		-log(pvalue)
	output is :
		-log(pvalue) qvalue
EOH
exit(1);
}

#my $m = $ARGV[1];
my $m = 38977850;
my $counter= 38977850;
open(INPUT, $ARGV[0]) or die "cannot open file !\n";

while(my $a = <INPUT>){
	next if $a=~/^#/;
	chomp $a;
	my $b = -1*$a;
	my $pval = 10**$b;
	#print "$pval\n";
	my $qval = $pval*$m/$counter;
	print "$a\t$qval\n";
	$counter--;
}
close(INPUT);
