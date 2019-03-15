#!/usr/bin/perl -w
#this script extracts all lines with a 

use strict;
unless(@ARGV==2){
	print <<EOH;
	usage $0 <file to read> <threshold>
		eg $0 11084_vec_inorder.txt.out.pval 1e-9
	Extracts all lines in file with 3rd column less than a threshold
	eg (1e-6))))))))). I use this for output of 'runchisq' C-program.
EOH
exit(0);
}
#set this to desired cut off value
my $threshold = $ARGV[1];
#my $threshold = 1e-9;  #mouse t31 10865 markers
#my $threshold = 1e-5;
#my $threshold = 1e-11;  #18577 G3 human
#my $threshold = 2e-9;  #dog 9775 markers
open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	my $pval = $line[2];
	if (($pval < $threshold) && ($pval != 0)){
		print join("\t", @line), "\n";
	}
}
