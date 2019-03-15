#!/usr/bin/perl -w
#
# find the closest human zero-gene eqtl for a given mouse zero-gene eqtl
use strict;
use Math::Round;
use Data::Dumper;

# Store the human zero-gene eQTLs
my %humzgqtl = ();
open(INPUT, "uniq_markers300k_zerog_pos.txt") || die "cannot open human zero g file\n";
while(<INPUT>){
	next if /^#/;
	next if /^M/;
	chomp;
	my @line = split(/\t/);
	#store midpoint of position
	push @{$humzgqtl{$line[0]}{pos}},  round(($line[1]+$line[2])/2);
	#store index 1..235829
	push @{$humzgqtl{$line[0]}{idx}},  $line[3];
}

close(INPUT);

# store mouse->hum transl table
my %mousetransl = ();
#open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/mus_hg18_pos_coordonly.txt") || die "croak\n";
open(INPUT, "/media/G3data/mm7tohg18/markers/mus2hum_markers_imputed.txt") || die "croak\n";
while(<INPUT>){
		next if /^#/;
		next if /^M/;
		chomp;
		my @line = split(/\t/);
		$line[0] =~ s/_random//ig;
		my($chr) = $line[0] =~ /(\d+).*/;
		$mousetransl{ $line[3] } = join("\t", $chr, $line[1], $line[2]);
}
close(INPUT);

# for each mouse zerog QTL, find position, find closest human zero-gene QTL
my $flag;
my $closest;
open(INPUT, "../mouse/0_gene_300k_trans_4.0.txt") || die "can't open zero gene mouse stuff\n";
#open(INPUT, "./mouse/mouse_non0.txt") || die "can't open zero gene mouse stuff\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		$flag = 1;
		my($tchr, $tstart, $tend);
		my @line = split(/\t/);
		if (exists $mousetransl{ $line[2] }){
			($tchr, $tstart, $tend) = split(/\t/, $mousetransl{ $line[2] });
		} else {
			next;
		}
		$closest=0;
		for (my $i=0; $i < scalar @{$humzgqtl{$tchr}{pos}}; $i++){
			if ( abs($tstart - ${$humzgqtl{$tchr}{pos}}[$i]) < $tstart - ${$humzgqtl{$tchr}{pos}}[$closest]){
				$closest = $i;
			}
		}
		#print mouse marker idx, chr, start, closest hum idx, closest hum pos
		print "$line[2]\t$tchr\t$tstart\t";
		print "${$humzgqtl{$tchr}{idx}}[$closest]\t";
		print "${$humzgqtl{$tchr}{pos}}[$closest]\n";
}

