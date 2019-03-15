#!/usr/bin/perl -w

$t="\t";
$n="\n";

$file=$ARGV[0];

open(HANDLE,$file);
for ($i=0; $i<10; $i++) {
$header=<HANDLE>;
}

while(<HANDLE>) {
	chomp $_;

	(undef, undef, undef, undef, undef,	
	 undef, undef, undef, undef, $probe, 
	 undef,	 $pos, undef, undef, undef, $log_ratio	)=split( "\t", $_);
	
if ($pos =~ /chr/ && $pos !~ /ran/ ) {
 	$pos=~s/:/\t/g;
	$pos=~s/-/\t/g;
	unless ($pos=~/\t/) { $pos=~s/$/\t\t/g;}
	print $probe.$t.$pos.$t.$log_ratio.$n;
}
}
close(HANDLE);

