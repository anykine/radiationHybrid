#!/usr/bin/perl -w

use strict;
use Data::Dumper;

unless(@ARGV==1){
	print <<EOH;
	usage $0 <rh file>	
	
	Calc retention freq by RH cell line. File format is:
	index chrom start stop c1 .. cNN
EOH
exit(1);
}

my $skipcols = 4;
my @cols = ();
my @matrix = ();
open(INPUT, $ARGV[0]) or die "cannot open $ARGV[0] for read!\n";
$_=<INPUT>;
my @jnkcols = split(/\t/, $_);
print $#jnkcols,"\n";
#for (my $i=$skipcols-1; $i<=$#jnkcols-$skipcols-1; $i++){
for (my $i=4; $i<=$#jnkcols; $i++){
	push @cols, $i;
}
print "@cols\n";
while(<INPUT>){
	my @tmp = split(/\t/);	
	push @matrix, [ @tmp[@cols] ];
}

my $count=0;
my $retained = 0;
for (my $cell=0; $cell<=$#cols; $cell++){
	for (my $i=0; $i<=$#matrix; $i++){
		$count++;
		$retained++ if $matrix[$i][$cell] == 1;
	}
	print "$cell retains ", $retained/$count, "\n";
	$count=0;
	$retained = 0;
}
