#!/usr/bin/perl -w

use strict;
unless(@ARGV==1){
	print <<EOH;
	usage $0 <file>
		$0 dog_all_qvals_sorted.txt
	
Reorder the qvals on a single file of input.
EOH
exit(1);
}

my ($i,$j);
my $tmpvar;
	open(INPUT, "$ARGV[0]") or die "cannot open file $i\n";
	my @bigarray = <INPUT>;
	close(INPUT);
	#print "size of array is ", scalar @bigarray, "\n";
	#start at top and reorder in decres size
	for($j=1; $j <= $#bigarray; $j++) {
		my $prevguy=(split(/\t/,$bigarray[$j-1]))[1];
		chomp($prevguy);
		my $thisguy=(split(/\t/,$bigarray[$j]))[1];
		chomp($thisguy);
		if ( $prevguy < $thisguy){
			#set thisguy's qval to prevguy's pval
			my @t = split(/\t/,$bigarray[$j]);
			$bigarray[$j]="$t[0]\t".(split(/\t/,$bigarray[$j-1]))[1];
			print $bigarray[$j];
			#$bigarray[$i]=$bigarray[$i+1];
		} else {
			#otherwise just print cur qval
			#print "cur=";
			print $bigarray[$j];
		}
	} #for loop
