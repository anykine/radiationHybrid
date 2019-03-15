#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;
my $DEBUG = 1;

# Do mouse and human zero-gene eQTLs within RADIUS
# regulate the same genes?
#

my %mousezg=();

# store the gene-marker pair for zero-gene QTL for mouse
sub load_mousezg{
	#format trans | mouse gene | mouse marker | alpha | nlp 
	open(INPUT, "./mouse/0_gene_300k_trans_4.0.txt") || die "cannot open mouse zg qtl file";
	while(<INPUT>){
		next if /^#/;
		chomp;
		my @line = split(/\t/);
		#marker may regulate mult genes, store all genes
		push @{$mousezg{$line[2]}} , $line[1];
	}
	print Dumper(\%mousezg) if $DEBUG;
}

my %humanzg=();
# store the gene-marker pair for zero-gene QTL for human
sub load_humang{
	#format hum gene | hum marker | alpha | nlp
	open(INPUT, "./new/zero_gene_peaks_ucschg18.txt") || die "cannot open human zg qtl file\n";
	#open(INPUT, "zero_gene_peaks_ucschg18.txt") || die "cannot open human zg qtl file\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		my @line = split(/\t/);
		#marker may regulate mult genes, store all genes
		push @{$humanzg{$line[1]}}, $line[0];
	}
	print Dumper(\%humanzg) if $DEBUG;
}

my %comh2m=();
my %comm2h=();
# load common gene index (same gene names between agil and ilmn)
sub load_common_geneidx{
	#format hum gene id | mouse gene id
	open(INPUT, "../comp_MH_regulators/common_human_mouse_indexes.txt") || die "cannot open common index\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		my @line = split(/\t/);
		$comh2m{$line[0]} = $line[1];
		#$comm2h{$line[1]} = $line[0];
		push @{$comm2h{$line[1]}} , $line[0];
	}
}

# scan nearest mus/hum nearest qtl file and see if pair regulates same gene
# within $radius
sub find_common_regulatee{
	my ($radius) = @_;
	my $sum=0;
	open(INPUT, "mus_hum_neaest_zerg_imputed.txt") || die "cannot open nearest QTL file\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		my @line = split(/\t/);
		if ( abs( $line[2]-$line[4]) <= $radius)	{
			#check if the mus and hum markers regulate common genes 
			print "checking at radius $radius\n" if $DEBUG;
			my $res = check_for_common($line[0], $line[3]);
			$sum += $res;
		}
	}
	print "sum=$sum\n";
}

sub check_for_common{
	my ($mus, $hum) = @_;
	my $res = 0;
	print "check common musmarker $mus hummakrer $hum\n" if $DEBUG;
	#iter over mouse array, hum array of genes
	foreach my $m (@{$mousezg{$mus}}) {
		print "checking mouse $m\n" if $DEBUG;
		foreach my $j (@{$humanzg{$hum}}) {
				
			print "checking hum $j\n" if $DEBUG;
			if (defined $comm2h{$m}){
				#return 1 if $comm2h{$m} == $j
				# use this if some genes have synonyms 
				foreach my $c (@{$comm2h{$m}}){
					if ($c==$j){
						print "mouse marker/gene $mus $m, human marker/gene $hum $j\n";
						$res++;
						#return 1; 
					}
				}
			}
		}
	}
	return $res;
}

#### run ###
load_mousezg();
load_humang();
load_common_geneidx;
#find_common_regulatee(15000);
find_common_regulatee(1000000);
