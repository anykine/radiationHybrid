#!/usr/bin/perl -w
#josh's qval calculator
#pass in file of increase pvals, returns qvals for those pvals

$t="\t";
$n="\n";


$file=$ARGV[0];
open(HANDLE,$file);
@ps=();

$newindex=0;
while(<HANDLE>) {
	chomp $_;
	$ps[$newindex]=$_;
	$newindex++;
}
close(HANDLE);



$length = scalar @ps;

@tpvals=();
for ($i=0; $i<$length; $i++ ) {
	$tpvals[$i]=$ps[$i]*($length/($i+1));
}


for ($i=$length-2; $i>=0; $i=$i-1 ) {
	if ($tpvals[$i+1] < $tpvals[$i] ) {
		$tpvals[$i]=$tpvals[$i+1];
	}
}


for ($i=0; $i<$length; $i++) {
	printf "%e\n", $tpvals[$i];
}
