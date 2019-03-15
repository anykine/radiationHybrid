#!/usr/bin/perl -w
use strict;
# Determine how much of the genome varies in copy number
# in TCGA samples.
# Criteria 1. CGH intensity must be +/- 1.2
# Criteria 2. 2 consecutive markers
#

my $thresh = 1.2;
# read the whole thing into memory
my @matrix = ();
#open(INPUT, "all.cghhapmap.scaled.colOrder.txt_smoothed.input1") || die "err $!";
open(INPUT, "allcgh.sort.2.matlab") || die "err $!";
while(<INPUT>){
	push @matrix, [ split(/\t/) ];	
}

# for all chroms, except X 
for (my $i=0; $i< 215720; $i++){
	for (my $j = 0; $j< 237; $j++){
		if ($matrix[$i][$j] > $thresh || $matrix[$i][$j] < ($thresh*-1)){
			$matrix[$i][$j] = 1;
		} else {
			$matrix[$i][$j] = 0;
		}
	}
}

#sum across row to get idea of coverage
my @rowsum=();
for (my $i=0;$i < 215720; $i++){
	my $sum = 0;
	for (my $j=0; $j<237; $j++){
		$sum += $matrix[$i][$j];
	}
	$rowsum[$i] = $sum;
}

my $rowsum = 0;
for (my $i=0;$i < 215720; $i++){
	$rowsum++  if $rowsum[$i] > 1;
}
print "autosomal coverage is ", $rowsum/215720, "\n";

## X chrom
my %females=();
open(INPUT, "female.idx") || die "err $!";
while(<INPUT>){
	chomp; next if /^#/; my(undef, $idx) = split(/\t/);
	$females{$idx} = 1;
}


### 2 consecutive 1's
for (my $j = 0; $j< 237; $j++){
	for (my $i=1; $i< 215720-1; $i++){
		if (($matrix[$i][$j] ==1 && $matrix[$i-1][$j]==1) || ($matrix[$i][$j] ==1 && $matrix[$i+1][$j]==1)){
			$matrix[$i][$j] = 1;
		} else {
			$matrix[$i][$j] = 0;
		}
	}
}
for (my $i=0;$i < 215720; $i++){
	my $sum = 0;
	for (my $j=0; $j<237; $j++){
		$sum += $matrix[$i][$j];
	}
	$rowsum[$i] = $sum;
}

$rowsum = 0;
for (my $i=0;$i < 215720; $i++){
	$rowsum++  if $rowsum[$i] > 1;
}
print "autosomal coverage (2-consecutive) is ", $rowsum/215720, "\n";

