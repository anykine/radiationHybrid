#!/usr/bin/perl -w
#
#determine breakpoints in mouse cis data
#
my $m = 7308422;
my $flag5 = 0;
my $flag4 = 0;
my $flag3 = 0;
my $flag2 = 0;
my $flag1 = 0;
my $flag05 = 0;
my $flag01 = 0;
my $flag001 = 0;
my $counter = 0;
open(INPUT, "test.qval.reorder") or die "cannot open file\n";
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
