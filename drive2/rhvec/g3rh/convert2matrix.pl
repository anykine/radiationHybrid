#!/usr/bin/perl -w

use strict;
use Data::Dumper;
unless(@ARGV==1){
	print <<EOH;
	usage $0 <file> 
	 eg  ./convert2matrix.pl extractg3-spot2.pos.txt > extractg3-spot2.mat.txt

	Read in the genome pval file and output a matrix for matlab.
EOH
exit(0);
}

open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
my $hashref = {};
while(<INPUT>){
	chomp;
	#use columns 2,4,5 (pos1,pos2,pval)
	my @data = split(/\t/);	
	$hashref->{$data[1]}{$data[3]}=$data[4];
}
close INPUT;

#write out file
#print Dumper($hashref);
for my $i (sort keys %$hashref){
	for my $j (sort keys %{$hashref->{$i}}){
		#print "$i\t$j\t$hashref->{$i}{$j}\n";
		print "$hashref->{$i}{$j}\t";
	}
	print "\n";
}
