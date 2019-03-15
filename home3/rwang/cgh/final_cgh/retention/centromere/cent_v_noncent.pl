#!/usr/bin/perl -w
#
# split each chrom into centromeric and noncentromeric sections
# and calc retention frequency separate for those regions
use strict;
use Data::Dumper;

#retfreq
open(INPUT, "../g3retention_freq.txt") or die "cannot open rf file\n";
#centromere +/- 4MB
open(INPUT1, "hg18centromere_gap1.txt") or die "cannot open cent file\n";

my $w = 4000000;
my %centromeres=();
while(<INPUT1>){
	next if ($. == 1);	
	chomp;
	my @line = split(/\t/);
	$centromeres{$line[0]} = {'start' => $line[1], 'end' => $line[2]};
}
close(INPUT1);

my %centnoncent=();
while(<INPUT>){
	chomp;
	my @marker = split(/\t/);
	my $mpos = ($marker[2]+$marker[3])/2;
	print "@marker", "\t", "st=$centromeres{$marker[1]}{'start'}\n"; 
	if (($centromeres{$marker[1]}{'start'} == 1) && ($mpos > ($centromeres{$marker[1]}{'end'}+$w))) {
		push @{$centnoncent{$marker[1]}{'noncent'}}, $marker[4];
	} elsif ( $mpos < ($centromeres{$marker[1]}{'start'}-$w))  {
		push @{$centnoncent{$marker[1]}{'noncent'}}, $marker[4];
	}elsif ($mpos > ($centromeres{$marker[1]}{'end'}+$w)){
		push @{$centnoncent{$marker[1]}{'noncent'}}, $marker[4];
	} else {
		push @{$centnoncent{$marker[1]}{'cent'}}, $marker[4];
	}
}
#print Dumper(\%centnoncent);
#calc average
foreach my $chrom (sort keys %centnoncent){
#	print "$chrom\t",avg(\@{$centnoncent{$chrom}{'cent'}});
#	print "\t",avg(\@{$centnoncent{$chrom}{'noncent'}});
#	print "\n";
	print "$chrom\t", join("\t",@{$centnoncent{$chrom}{'cent'}}), "\n";
	print "$chrom\t", join("\t",@{$centnoncent{$chrom}{'noncent'}}), "\n";
}

sub avg {
	my $aref = shift;	
	my $sum = 0;
	foreach my $n (@{$aref}) {
		$sum += $n;
	}
		return $sum/scalar @{$aref};
}
