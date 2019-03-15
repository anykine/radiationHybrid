#!/usr/bin/perl -w
# 
# clean up file idx1=1 idx2=2 prob=6.99e-10

unless (@ARGV ==1) {
	print <<EOH;
	usage $0 <file to pretty>

  Clean up file idx1=1 idx2=2 prob=6.99e-10 by
	removing idx1=, idx2=, prob=
EOH
exit(0);
}
open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
while (<INPUT>) {
	s/idx[12]=//ig;
	s/prob=//ig;
	print $_;
	
}
