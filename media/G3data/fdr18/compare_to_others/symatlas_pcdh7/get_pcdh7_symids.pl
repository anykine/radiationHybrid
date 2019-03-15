#!/usr/bin/perl -w 
$t="\t";
$n="\n";


#$file="/home/josh/Desktop/llids_pcdh7_fdr20.txt";
$file="/home/josh/Desktop/symatlas_pcdh7/all_agilent_llids.txt";
%pcdh7_ll=();
open(HANDLE, $file);
while(<HANDLE> ) {
 chomp $_;
	$pcdh7_ll{$_}=1;
}
close (HANDLE);
$file="/home/josh/Desktop/symatlas_pcdh7/gnf1m_annot.txt";
$index=1;
open(HANDLE, $file);
while(<HANDLE>) {
	chomp $_;
($gnfid, undef, $nm, $gb, $gn, $ll ) = split("\t", $_);
	if (defined ($pcdh7_ll{$ll}) ) {
	
	print $ll.$t.$index.$n;
	}
$index++;
}
close (HANDLE);
