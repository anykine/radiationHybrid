use strict;
use Data::Dumper;


open(INPUT, "dog_fdr_inorder.e02.mat") || die "cannot open for read\n";
open(OUTPUT, ">dog_1000.mat") || die "cannot write";
my $count=0;

while(<INPUT>){
	$count++;
	print OUTPUT $_;
	
	if ($count>1000) {exit(1);}
	
}