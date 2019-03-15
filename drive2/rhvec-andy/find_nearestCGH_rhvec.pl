#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;
use lib '/home/rwang/lib';
use hummarkerpos;
use Math::Round;

# andy is going from human-> mouse, so let's scaffold
# his rh markers onto cgh markers to do the conversion.
#
# first, cgh markers are on hg18 build, so needed to 
# liftover to hg17 since rh markers are hg17
#
# take human rhvec markers, find closest hum AGIL CGH
# markers. Use result as input to liftOver



#load andy's 18000 hum markers
#sub load_rhvec_hum{
#	open(INPUT, "human_mm7_0.95_full.txt") || die "cannot open rhvec file\n";
#	while(<INPUT>){
#		chomp;
#		my @line = split(/\t/);
#		$line[0] =~ s/chr//;
#		$line[0] =~ s/^X/23/;
#		$line[0] =~ s/^Y/24/;
#		push @{$rhvec{$line[0]}{start}}, $line[1];
#		push @{$rhvec{$line[0]}{stop}}, $line[2];
#		push @{$rhvec{$line[0]}{idx}}, $.;
#	}
##print Dumper(\%rhvec);
#}

my %hummarkerpos=();
sub load_rhvec_humhg17{
	open(INPUT, "./hg18tohg17/hum_cgh_hg17.bed") || die "cannot open hum hg17 file\n";
	while(<INPUT>){
		chomp;
		my @line = split(/\t/);
		$line[0] =~ s/chr//;
		$line[0] =~ s/^X/23/;
		$line[0] =~ s/^Y/24/;
		push @{$hummarkerpos{$line[0]}{start}}, $line[1];
		push @{$hummarkerpos{$line[0]}{stop}}, $line[2];
		push @{$hummarkerpos{$line[0]}{pos}}, round(($line[1]+$line[2])/2);
		push @{$hummarkerpos{$line[0]}{idx}}, $.;
	}
}

#find the closest marker
sub find_nearest_humcgh{
	#iterate over human rhvec, then over hummarkerpos hash	
	open(INPUT, "human_mm7_0.95_full.txt") || die "cannot open rhvec file\n";
	while(<INPUT>){
		chomp;
		my @line = split(/\t/);
		$line[0] =~ s/chr//;
		$line[0] =~ s/^X/23/;
		$line[0] =~ s/^Y/24/;
		my $pos = round(($line[1]+$line[2])/2);
		my $closest=0;
		#search for closest CGH marker
		#print "array size for $line[0] is ", scalar @{$hummarkerpos{$line[0]}{pos}}, "\n";
		for (my $i=0; $i < scalar @{$hummarkerpos{$line[0]}{pos}}; $i++){
			if ( abs(${$hummarkerpos{$line[0]}{pos}}[$i] - $pos) < abs(${$hummarkerpos{$line[0]}{pos}}[$closest] - $pos)) {
				$closest = $i;
			}
		}
		print join("\t", @line[0,1,2]), "\t";
		print ${$hummarkerpos{$line[0]}{idx}}[$closest], "\t";
		print ${$hummarkerpos{$line[0]}{start}}[$closest], "\t";
		print ${$hummarkerpos{$line[0]}{stop}}[$closest], "\n";
	}
}

######## MAIN ##########3
# UNUSED load_rhvec_hum();
# called from hummarkerpos module
# cannot use markerpos from database because we need hg17 not hg18
#load_markerpos_from_db_range("g3data");
#print Dumper(\%hummarkerpos);


load_rhvec_humhg17();
find_nearest_humcgh();
