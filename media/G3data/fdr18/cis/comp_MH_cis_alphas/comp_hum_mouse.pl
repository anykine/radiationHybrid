#!/usr/bin/perl -w
#
# extract the relevant columns from human peaks and mouse peaks
# based on gene index file

use strict;
unless (@ARGV == 2){
	print <<EOH;
	usage: $0 <human nlp> <mouse nlp>
	Extract the corresponding alphas for human/mouse genes at -logp threshold

EOH
exit(1);

}

#thresholds
my $mouse_nlp = $ARGV[1];
my $human_nlp = $ARGV[0];

open(MOUSE, "mouse_cis_peaks_FDR40.txt") || die "cannot open mouse\n";
open(HUMAN, "human_cis_peaks_FDR40.txt") || die "cannot open mouse\n";
open(INDEX, "common_human_mouse_indexes.txt") || die "cannot read indexes\n";

my %mouse = ();
my %human = ();

#print "HUMAN\n\n";
while(<HUMAN>){
	chomp;
	my @line = split(/\t/);
	# if its above threshold
	if ($line[3] >= $human_nlp){
		#store alpha 
		$human{$line[0]} = $line[2];
#		print "$line[0] = $human{$line[0]}\n";
	}
}
close(HUMAN);

#print "MOUSE\n\n";
while(<MOUSE>){
	chomp;
	my @line = split(/\t/);
	if ($line[3] >= $mouse_nlp){
		$mouse{$line[0]} = $line[2];
#		print "$line[0] = $mouse{$line[0]}\n";
	}
}
close(MOUSE);

<INDEX>;
while(<INDEX>){
	chomp;
	my ($hidx, $midx) = split(/\t/);
	if (defined $human{$hidx} ) {
		if (defined $mouse{$midx}) {
			print "$hidx\t";
			print "$human{$hidx}\t";
			print "$midx\t";
			print "$mouse{$midx}\n";
		}
	}
}
