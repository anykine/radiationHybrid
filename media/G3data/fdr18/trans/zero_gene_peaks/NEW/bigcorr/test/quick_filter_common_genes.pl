#!/usr/bin/perl -w
#
# test2002 code gets rid of redundent genes
# this strips common_human_mouse_indexes
# so there is 1-hum-1-mus
use strict;

my %hum2mus=();
open(INPUT, "/media/G3data/fdr18/cis/comp_MH_cis_alphas/common_human_mouse_indexes.txt") || die "cannot open common file\n";
<INPUT>;
while(<INPUT>){
	chomp;
	my @data = split(/\t/);
	$hum2mus{$data[0]} = $data[1];
}

foreach my $i (keys %hum2mus){
	print "$i\t$hum2mus{$i}\n"; 
}
