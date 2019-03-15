#!/usr/bin/perl -w
#
# extract the relevant columns from human peaks and mouse peaks
# based on gene index file
# 9/7/10 - updated for 2mb cis
use strict;
use Data::Dumper;

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

open(MOUSE, "../../comp_MH_cis_alphas/mouse_cis_peaks_FDR40.txt") || die "cannot open mouse\n";
open(HUMAN, "../cis_FDR40_annot.txt") || die "cannot open mouse\n";
open(INDEX, "../../comp_MH_cis_alphas/common_human_mouse_indexes.txt") || die "cannot read indexes\n";

my %mouse = ();
my %human = ();

#print "HUMAN\n\n";
while(<HUMAN>){
	chomp;
	my @line = split(/\t/);
	# if its above threshold
	if ($line[7] >= $human_nlp){
		#store alpha 
		#$hhuman{$line[4]} = $line[2];
		$human{$line[4]} = {
			chrom => $line[0],
			start => $line[1],
			stop  => $line[2],
			sym   => $line[3],
			marker=> $line[5],
			alpha => $line[6]
		}
#		print "$line[0] = $human{$line[0]}\n";
	}
}
close(HUMAN);
#print Dumper(\%human);exit(1);

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
			print join("\t", 
				$human{$hidx}{chrom},
				$human{$hidx}{start},
				$human{$hidx}{stop},
				$hidx,
				$human{$hidx}{alpha},
				$midx,
				$mouse{$midx}
				),"\n";
		}
	}
}
