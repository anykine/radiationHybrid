#!/usr/bin/perl -w
#
open(INPUT, "mou_fdr_inorder.txt.e02") or die "cannot open file\n";
open(OUT1, ">mou_fdr_inorder.txt.e02.1-6000");
open(OUT2, ">mou_fdr_inorder.txt.e02.6000-11084");
while(<INPUT>){
	my @data = split(/\t/);
	if ($data[0] < 6001) {
		print OUT1 join("\t", @data);
	} else {
		print OUT2 join("\t", @data);
	}


}
