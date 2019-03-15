#!/usr/bin/perl -w
use strict;
#
#put the rvalue file (genespring normalized) into gene order
#according to the expr_pos_name.txt file
# rval file is |probeid|human expr|ham expr|<blank>|rval
#
my %rvals = ();
open(INPUT, "r-value-genespring-clean_inorder_final.csv") || die "cannot open input\n";
<INPUT>; #skip header
while(<INPUT>){
	chomp;
	my @line = split(/,/);
	$rvals{$line[0]} = $line[4];
}
close(INPUT);
#print "num of keys is ", scalar (keys %rvals), "\n";

#put in same order as gene data
open(INPUT, "../../../expr/phase2/expr_pos_name.txt") || die "cannot open pos\n";
<INPUT>; #skip header
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	print "$line[3]\t$rvals{$line[3]}\n";

}
