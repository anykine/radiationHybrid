#!/usr/bin/perl -w
#
# Des' idea about finding zero-gene eQTL's using bordering genes.
# UNFINISHED
# For the zero-gene ceQTL's, find the 2 closest genes (up/down stream).
#
use strict;
use humgenepos;
use Data::Dumper;
use Math::Round;

unless (@ARGV==1){
	print <<EOH;
	$0 <input file>
	 $0 uniq_markers300k_zerog_pos.txt
	
	Find the genes that border each ceQTL
EOH
exit(1);

}

### %humgenepos() imported from humgenepos
my %zerogenes = ();
for (my $i=1; $i<25; $i++){
	$zerogenes{$i}{pos} = [];
	$zerogenes{$i}{idx} = [];
}
print Dumper(\%zerogenes);

open(INPUT, $ARGV[0]) || die "cannot open input file\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my($chrom,$start,$end,$idx) = split(/\t/);
	my $pos = round(($start+$end)/2);
	print $pos; exit(1);
}

