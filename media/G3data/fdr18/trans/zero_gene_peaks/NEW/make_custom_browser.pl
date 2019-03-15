#!/usr/bin/perl -w
#
# create a custom BED track, marker position & score(highest nlp value)
#

use strict;
use lib '/home/rwang/lib';
use hummarkerpos;
use Math::Round;

my %scores = ();

# find the highest nlp for ea marker
sub load_zerogene_markers{
	open(INPUT, "zero_gene_peaks_ucschg18.txt") || die "file $!\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		my @line = split(/\t/);
		if (defined $scores{$line[1]} ){
			$scores{$line[1]} = $line[3] if $scores{$line[1]} < $line[3];
		} else {
			$scores{$line[1]} = $line[3];
		}
	}
	#print "size of hash is ". scalar (keys %scores) . "\n";
	close(INPUT);
}

#bed format is chrom start stop name score
sub make_BEDtrack{
	my @markers = sort {$a<=>$b} keys %scores;
	print "track name=zerog description='zero gene eQTL' visibility=4 useScore=1\n";
	foreach my $i (@markers){ 
		print $hummarkerpos_by_index{$i}{chrom}, "\t";
		print $hummarkerpos_by_index{$i}{start}, "\t";
		print $hummarkerpos_by_index{$i}{stop}, "\t";
		print $i,"\t";
		#score is between 1-1000
		print round($scores{$i}*100),"\n";
	}

}


###### run ##########
# from hummarkerpos
load_markerpos_by_index("g3data");
load_zerogene_markers();
make_BEDtrack();
