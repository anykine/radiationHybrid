#!/usr/bin/perl -w

$file="agilent_sym_id.txt";
%sym_on_ag=();
open(HANDLE, $file);
while (<HANDLE> ) { 
	chomp $_;
	$sym_on_ag{$_}=1;
}	
close (HANDLE);

$file= "/home/josh/Desktop/symatlas_pcdh7/sym_atlas_unlogged.txt";
$index=1;
open (HANDLE, $file);
while (<HANDLE>) {
	
	if (defined $sym_on_ag{$index} ) {
		print $_;
	}
	$index++;
}
close (HANDLE);
