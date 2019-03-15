#!/usr/bin/perl -w
#
#open(INPUT, "/media/usbdisk/tcga/cgh/level1/TCGA-12-0819-01A-01D-0387-02_S01_CGH-v4_10_Apr08.txt") || die "err";
#open(INPUT, "/media/usbdisk/tcga/cgh/level1/TCGA-12-0820-01A-01D-0387-02_S01_CGH-v4_10_Apr08.txt") || die "err1";
open(INPUT, "/media/usbdisk/tcga/cgh/level1/TCGA-12-0821-01A-01D-0387-02_S01_CGH-v4_10_Apr08.txt") || die "err1";

while(<INPUT>){
	chomp; 
	my @d = split(/\t/);
	my $probe = $d[9];
	my $ch1= $d[22];
	my $ch2= $d[23];
	print $probe,"\n";
}
