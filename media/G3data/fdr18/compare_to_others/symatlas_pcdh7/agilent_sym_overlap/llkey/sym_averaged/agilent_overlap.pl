#!/usr/bin/perl -w 
$t="\t";
$n="\n";


#$file="/home/josh/Desktop/llids_pcdh7_fdr20.txt";
#$file="/home/josh/Desktop/symatlas_pcdh7/all_agilent_llids.txt";

$file= "all_agilent_llids.txt";
%pcdh7_ll=();
open(HANDLE, $file);
while(<HANDLE> ) {
 chomp $_;
	$pcdh7_ll{$_}=1;
}
close (HANDLE);

$annot="sym_unlogged_averaged_llkey.txt";
open(HANDLE, $annot);
$data="sym_unlogged_averaged.txt";
open(DATA, $data);

while(<HANDLE>) {
	chomp $_;
	$d=<DATA>;	

	if(defined( $pcdh7_ll{$_} ) ){
	print $_.$t.$d;
	}

}
close (HANDLE);
close (DATA);
