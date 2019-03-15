#!/usr/bin/perl -w
#
#determine breakpoints in mouse trans data, fdr18, modified 6/18/09
# for fdrs bewtween 20-30
use strict;
use Data::Dumper;
#my $m = 4926156806;
my $m = 4932164087;
#my $m = 7;
my $flag5 = 0;
my $flag4 = 0;
my $flag3 = 0;
my $flag2 = 0;
my $flag1 = 0;
my $flag05 = 0;
my $flag01 = 0;
my $flag001 = 0;
my $counter = 0;

my %fdr=();
for (my $i=20; $i<=30; $i++){
	$fdr{$i} = 0;
}
#open(INPUT, "trans_final.txt") or die "cannot open file\n";
open(INPUT, "trans_allp_qval.txt") or die "cannot open file\n";
#open(INPUT, "test.1.in") or die "cannot open file\n";
print "pval\t-logp\tfdr\tpos\n";
while(<INPUT>){
	chomp;
	my @data = split(/\t/);
	$counter++;
	if ($data[1] <= 0.3 && $data[1] >0.29 && $fdr{30}==0) {
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$fdr{30} = 1;
	} elsif ($data[1] <= 0.29 && $data[1] > 0.28 && $fdr{29}==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$fdr{29} = 1;
	} elsif ($data[1] <= 0.28 && $data[1] > 0.27 && $fdr{28}==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$fdr{28} = 1;
	} elsif ($data[1] <= 0.27 && $data[1] > 0.26 && $fdr{27}==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$fdr{27} = 1;
	} elsif ($data[1] <= 0.26 && $data[1] > 0.25 && $fdr{26}==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$fdr{26} = 1;
	} elsif ($data[1] <= 0.25 && $data[1] > 0.24 && $fdr{25}==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$fdr{25} = 1;
	} elsif ($data[1] <= 0.24 && $data[1] > 0.23 && $fdr{24}==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$fdr{24} = 1;
	} elsif ($data[1] <= 0.23 && $data[1] > 0.22 && $fdr{23}==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$fdr{23} = 1;
	} elsif ($data[1] <= 0.22 && $data[1] > 0.21 && $fdr{22}==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$fdr{22} = 1;
	} elsif ($data[1] <= 0.21 && $data[1] > 0.20 && $fdr{21}==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$fdr{21} = 1;
	} elsif ($data[1] <= 0.20 && $data[1] > 0.19 && $fdr{20}==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$fdr{20} = 1;
	}
}
#print Dumper(\%fdr);
