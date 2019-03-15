#!/usr/bin/perl -w
#
# extract the relevant columns from human peaks and mouse peaks
# based on gene index file

use strict;
unless (@ARGV == 2){
	print <<EOH;
	usage: $0 <human file> <mouse file>
	Extract the #'s regulating genes in human/mouse

EOH
exit(1);

}

open(HUMAN, "$ARGV[0]") || die "cannot open human\n";
open(MOUSE, "$ARGV[1]") || die "cannot open mouse\n";
open(INDEX, "common_human_mouse_indexes.txt") || die "cannot read indexes\n";

my %mouse = ();
my %human = ();

#print "HUMAN\n\n";
while(<HUMAN>){
	chomp;
	my @line = split(/\t/);
	# if its above threshold
		#store trans
		$human{$line[0]} = $line[2];
#		print "$line[0] = $human{$line[0]}\n";
}
close(HUMAN);

#print "MOUSE\n\n";
while(<MOUSE>){
	chomp;
	my @line = split(/\t/);
		$mouse{$line[0]} = $line[1];
#		print "$line[0] = $mouse{$line[0]}\n";
}
close(MOUSE);

#debug
print "sizeof human=", scalar (keys %human), "\n";
print "sizeof mouse=", scalar (keys %mouse), "\n";
#exit(1);
#<INDEX>;
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
