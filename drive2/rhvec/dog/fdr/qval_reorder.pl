#!/usr/bin/perl -w

use strict;
unless(@ARGV==1){
	print <<EOH;
	usage $0 <file with qvalues>
		$0 dog_all_qvals_sorted.txt
	
	implements the reordering procedure for BH fdr calc
EOH
exit(1);
}

open(INPUT, $ARGV[0]) or die "cannot open file\n";
my @bigarray = <INPUT>;
#start at bottom and reorder in incres size
for(my $i=$#bigarray-1; $i !=-1; $i--) {
	#print $i,"\n";
	my $tmp1=(split(/\t/,$bigarray[$i+1]))[3];
	chomp($tmp1);
	my $tmp2=(split(/\t/,$bigarray[$i]))[3];
	chomp($tmp2);
	#print "$tmp1\t|\t$tmp2\n";	
	if ( $tmp1 < $tmp2 ){
	#if ( (split(/\t/,$bigarray[$i+1]))[3] < (split(/\t/,$bigarray[$i]))[3] ){
		my @t = split(/\t/,$bigarray[$i]);
		$bigarray[$i]="$t[0]\t$t[1]\t$t[2]\t".(split(/\t/,$bigarray[$i+1]))[3];
		#$bigarray[$i]=$bigarray[$i+1];
	}
}
print "@bigarray\n";
