#!/usr/bin/perl -w

use strict;
#
# modified by richard 11/14/2008
# need to get the alphas for all cis genes
# extract using these and then run peak finder....

use Data::Dumper;

open (PROBEFILE, "../index/probe_gc_coords.txt") or die "cannot open probe coords\n";
open (MARKERFILE, "../index/marker_gc_coords.txt") or die "cannot open marker coords\n";

my @exp = ();
my @cgh = ();


while (<PROBEFILE>)
{
	chomp;
	push @exp, $_;
}

while (<MARKERFILE>)
{
	chomp;
	push @cgh, $_;
}



# usage of sample module
#@sample =  sample (set => \@josh, sample_size=>3);

open (CISFILE, ">mouse_cis_alpha_nothresh.txt") or die "cannot write cis\n";
open (TRANSFILE, ">mouse_trans_alpha_nothresh.txt") or die "cannot write trans\n";

open (NLPFILE, "../nlp_perm_grid.txt") or die "cannot find nlp grid\n";
# this alpha has X/Y values scaled. The original alpha_grid.txt file was not
# scaled, josh only scaled the alphas after peak finding....
open (ALPHAFILE, "../alp_grid_scaled.txt") or die "cannot find alp grid\n";
#$m=1;

my $transcount = 0;
my $ciscount = 0;

for (my $m=0; $m<232626; $m++ ) {
	
	$_=<NLPFILE>;	
	chomp $_;
	my @nlpline = split ("\t", $_);
	$_=<ALPHAFILE>;
	chomp $_;
	my @alpline = split ("\t", $_);
	for (my $i=0; $i<20145; $i++) {
		if ( abs($exp[$i]-$cgh[$m])>10000000 ) {
#			if ($nlpline[$i] >= 3.99)
#			{
				#print TRANSFILE "$i+1\t$m+1\t$alpline[$i]\t$nlpline[$i]\n";
				$transcount++;
#			}
		} else {
#			if ($nlpline[$i] >= 3.99)
#			{
				#print $i . "\t" . ($m+1) . "\n" ;#."\t$alpline[$i]\t$nlpline[$i]\n";
				#print CISFILE $i+1 . "\t" . $m+1 ."\t$alpline[$i]\t$nlpline[$i]\n";
				
				#print gene
				print CISFILE $i+1 . "\t";
				#print marker
				print CISFILE $m+1 ."\t";
				print CISFILE "$alpline[$i]\t$nlpline[$i]\n";
				$ciscount++;
#			}
			
		}
	}

	
	if ($m%100 == 0) { print STDERR $m."\n";}
	
}
close (NLPFILE);

print STDERR "Size of trans = $transcount\n";
print STDERR "Size of cis = $ciscount\n";

close (TRANSFILE);
close (CISFILE);

