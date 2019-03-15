#!/usr/bin/perl -w
#
# For the 2700+ zero gene eqtl's (peak marker) ,
# are they in the human set within dist of RADIUS?
#
# The difference between this program and the find_nearest_eqTL.pl
# is that this uses the liftOver10 output, while the other
# uses the imputed as well.
use strict;
use Math::Round;
use Data::Dumper;
use lib '/home/rwang/lib';
use hummarkerpos;

unless (@ARGV==1){
	print <<EOH;
	$0 <radius> 
	 ($0 15000)

	Scan through list of mouse 0-gene eQTLs and find how many
	are within RADIUS of human 0-gene eQTL (using mus2hum liftover)
EOH
exit(1);

}
##########################################################
#### read in mus->human marker position translation table
##########################################################
my %trans=();
open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/mus_hg18_pos_coordonly.txt") || die "file open failed\n";
while(<INPUT>){
	next if /^#/;
	next if /^M/;
	chomp;
	my @line = split(/\t/);
	#get rid of _random; assume correct
	$line[0] =~ s/_random//ig;
	#use markerID as key
	$trans{$line[3]} = join("\t", $line[0], round(($line[1]+ $line[2])/2));
}
close(INPUT);
#print Dumper(\%trans);

##########################################################
# get human marker positions using module
##########################################################
#load_markerpos_from_db("g3data");
#print Dumper(\%hummarkerpos);

##########################################################
# get zerogene hum marker positions 
##########################################################
my %humzerog=();
open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/uniq_markers300k_zerog_pos.txt") || die "file open failure\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	push @{$humzerog{$line[0]}{idx}}, $line[3];
	push @{$humzerog{$line[0]}{pos}}, round(($line[1]+$line[2])/2);
}
close(INPUT);
#print Dumper(\%humzerog);

##########################################################
# read in mus zerog eqtl
##########################################################

my($chr,$pos);
my $counter=0;
my $radius = 10000;

#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/0_gene_300k_trans_4.0.txt") || die "file fail\n";
open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/0_gene_300k_trans_4.0_uniq.txt") || die "file fail\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	#print "--line @line\n";
	if ( exists $trans{$line[0]} ) {
		($chr,$pos) = split(/\t/, $trans{$line[0]}) ;
		#print "$chr and $pos\n";
	} else {
		next;
	}


	#search for nearby QTL in other human on chrom
	for(my $i=0; $i< scalar @{$humzerog{$chr}{pos}}; $i++){
		#print "subtracting $humzerog{$chr}{pos}[$i] from $pos\n";
		# if mus2hum position is close to human marker, count it
		if ( abs( $humzerog{$chr}{pos}[$i] - $pos) < $radius ) {
			#print "found one\t$counter\n";
			#print mouse marker| human marker
			my $diff = abs( $humzerog{$chr}{pos}[$i] - $pos); 
			print "$line[0]\t$humzerog{$chr}{idx}[$i]\t$diff\n";
		}
	}
	$counter++;
}
