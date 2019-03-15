#!/usr/bin/perl -w 
$t="\t";
$n="\n";

$file=$ARGV[0];
#$file="/home/josh/Desktop/llids_pcdh7_fdr20.txt";
#$file="/home/josh/Desktop/symatlas_pcdh7/all_agilent_llids.txt";
%pcdh7_ll=();
open(HANDLE, $file);
while(<HANDLE> ) {
 chomp $_;
	$pcdh7_ll{$_}=1;
}
close (HANDLE);

$file="new_sym_key.txt";
$index=1;
open(HANDLE, $file);
while(<HANDLE>) {
	chomp $_;
	if (defined ($pcdh7_ll{$_}) ) {
		print $index.$t.$_.$n;
	}
$index++;
}
close (HANDLE);
