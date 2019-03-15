#!/usr/bin/perl -w
$t="\t";
$n="\n";
$in=$ARGV[0];

%genes=();
open (HANDLE, $in);

while (<HANDLE>) { 
	chomp $_;
	($p , undef ) =	split ("\t", $_);
		$genes{$p}=1;
}
close (HANDLE);

$probes="/data0/Sangtae_Calc/index/microarray_genes/mm7_probes_master_info.txt";
open (HANDLE, $probes);
while (<HANDLE> ) {
	chomp $_;
	
 	($id, $chr, $start, $stop, $name, $unigenename, $ll, $gbacc, $sysname, $unigeneid) = split("\t", $_);
		if (defined $genes{$id}) {
			print $ll.$n;
		}
 }
 close (HANDLE);
