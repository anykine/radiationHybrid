#!/usr/bin/perl -w
use strict;
#
# determine breakpoints in data based on FDR levels
# of 40,30,20,10,5,1,0.1
#
# output: pval | -logpval | fdr | position in list
#
# read the output of qval.pl and qval_reorder3_mod.pl
#my $m = 38977850;
unless (@ARGV==2){
	print <<EOH;
	usage $0 <file to read> <length of file>
	 e.g. $0 hg18cis_qvals_reorder.txt 19301597 

	Determine breakpoints for FDR.
EOH
exit(1);
}

#my $m = 19308878;
my $m = $ARGV[1];
my $flag5 = 0;
my $flag4 = 0;
my $flag3 = 0;
my $flag2 = 0;
my $flag1 = 0;
my $flag05 = 0;
my $flag01 = 0;
my $flag001 = 0;
my $counter = 0;
#open(INPUT, "final_cis.txt") or die "cannot open file\n";
open(INPUT, $ARGV[0]) or die "cannot open file\n";
print "pval\t-logp\tfdr\tpos\n";
while(<INPUT>){
	chomp;
	my @data = split(/\t/);
	$counter++;
	if ($data[1] < 0.5 && $flag5==0) {
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$flag5 = 1;
	} elsif ($data[1] < 0.4 && $flag4==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$flag4 = 1;
	} elsif ($data[1] < 0.3 && $flag3==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$flag3 = 1;
	} elsif ($data[1] < 0.2 && $flag2==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$flag2 = 1;
	} elsif ($data[1] < 0.1 && $flag1==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$flag1 = 1;
	} elsif ($data[1] < 0.05 && $flag05==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$flag05 = 1;
	} elsif ($data[1] < 0.01 && $flag01==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$flag01 = 1;
	} elsif ($data[1] < 0.001 && $flag001==0){
		my $pos = $m - $counter;
		print 10**(-1*$data[0]),"\t";
		print "$data[0]\t$data[1]\t$pos\n";
		$flag001 = 1;
	}
}
