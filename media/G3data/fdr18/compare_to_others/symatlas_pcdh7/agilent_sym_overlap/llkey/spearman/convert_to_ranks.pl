#!/usr/bin/perl -w
$file="/home/josh/Desktop/symatlas_pcdh7/agilent_sym_overlap/llkey/sym_avg_ag_overlap_unlog.txt";
open (HANDLE, $file);
while (<HANDLE>) {
	chomp $_;
	@line =split ("\t" , $_);
	@id=();
	for ($i=0; $i<61; $i++ ) { push @id , $i ; }

	@sline= sort { $line[$id[$a]] <=> $line[$id[$b]] } @id;

	for ($j=0; $j<61; $j++ ) {
		$pr=$sline[$j]+1;
		print $pr."\t";
	}
	print "\n";
}
close (HANDLE);
