#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

my %selprobes=();
#read in final cgh probes
open(INPUT1, "indexFinalProbe.txt") || die "cannot open file1\n";
while(<INPUT1>){
	next if /^ProbeName/;
	chomp;
	$selprobes{$_} = 1;
}
close(INPUT1);
#print Dumper(\%selprobes);

#read the Agilent CGH master file
my %mastercgh=();
open(INPUT2, "mouse_CGH_master.txt") || die "cannot open file2\n";
while(<INPUT2>){
	next if /^Probe/;
	chomp;
	my($probe, $loc) = split(/\t/);
	#skip probes with no location
	if ($loc eq 'unmapped' ){
		next;
	}
	#filter if its a select probe
	if (exists $selprobes{$probe}) {
		print $probe, "\t";
		#print $loc, "\n";
		my ($chr,$start,$stop) = split(/[:-]/, $loc);
		#remove chr, change X and Y	
		$chr =~ s/chr//;
		$chr =~ s/X/20/;
		$chr =~ s/Y/21/;
		print "$chr\t$start\t$stop\n";	
	}
}
