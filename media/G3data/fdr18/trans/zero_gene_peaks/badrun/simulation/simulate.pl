#!/usr/bin/perl -w
#
# simulation to estimate zero-gene eqtls between human and mouse
# 1. randomly select 2700 eqtls from mouse set, then see how many are
#   still zero-gene in human. Do this N times to build distribution.
use strict;
use lib '/home/rwang/lib/';
use mysqldb;
use humgenepos;
use Data::Dumper;

# %humgenepos imported from humgenepos
my %mouseQTLpos=();
my @mouseQTLs=(); #all mouse eQTLs
my %mouse2humtransl=();

my %humzgqtl = (); #human 0-gene eQTLs

# SAMPLE how many are moues 0-gene are 0-gene in human
#UNUSED get_mouseQTLpos();
#get_mouse2humtransl();
#get_mouse_zerogeneQTLs();
#sample(1000);

# SAMPLE how many mouse 0-gene QTLs within radius of human 0-gene
get_mouse2humtransl();
get_mouse_zerogeneQTLs();
sampledist(1000, $ARGV[0]);

#build histogram

###########################################
#    
#    SUBROUTINES
#
###########################################

#store table of positions
sub get_mouseQTLpos{
	my $sql = "select idx,chrom,pos_start,pos_end from mouse_rhdb.cgh_pos order by idx";
	my $dbh = db_connect("mouse_rhdb");
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$mouseQTLpos{$rs[0]} = join(":", @rs[1,2,3]);
	}
	#print Dumper(\%mouseQTLs);
}

#read in a mus2hum liftover table
#chr | start | stop | marker id
sub get_mouse2humtransl{
	open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/mus_hg18_pos_coordonly.txt") || die "cannot open liftover file\n";
	while(<INPUT>){
		next if /random/;
		chomp;
		my @line = split(/\t/);
		next if $line[0] !~ /^-?\d+$/;
		$mouse2humtransl{$line[3]} = join(":", @line[0,1,2]);
	}
}

#create array of mouse QTL positions(transl into human genome) that could be liftedover
#to sample from
sub get_mouse_zerogeneQTLs{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/trans_peaks_3.99.txt") || die "cannot open mouse trans peaks";
	while(<INPUT>){
		chomp;
		my @line = split(/\t/);
			if (defined $mouse2humtransl{$line[1]}){
				push @mouseQTLs, $mouse2humtransl{ $line[1] };
			}
	}
	#free up some memory
	#print Dumper(\@mouseQTLs);
}

# do this sampling procedure N times to find if 0-gene still 0-gene
# between mouse and human
sub sample{
	my $reps = shift;
	my $range = @mouseQTLs;
	#load human gene positions from humgenepos pkg
	load_genepos_from_dbucsc("ucschg18");

	for (my $ii=0; $ii<= $reps; $ii++){
		print STDERR "iter $ii\n";
		#my @rands= (undef) x 2700;
		my @rands= (); 
		$#rands = 2699;
		my $sum = 0;
		#create array of 2700 random numbers
		for (my $i=0; $i<2700; $i++){
			#push @rands, int(rand($range));	
			$rands[$i] = int(rand($range));
		}
		print STDERR "size of rands is ",scalar @rands ,"\n";	
		foreach my $k (@rands){
			my ($tchr,$tstart,$tend) = split(/:/,$mouseQTLs[$k]);
			#print "$tchr $tstart $tend\n";
			my $res = is_still_zero_gene($tchr, $tstart,$tend);
			$sum = $sum + $res;
		}	
		print "$sum\n";
	}
}

#see if this mouseQTL is still zero-gene in human
sub is_still_zero_gene{
	my($tchr, $tstart,$tend) = @_;
	my $radius=300000;
	my $flag = 1;
	#search across human
	for (my $i=0; $i < scalar @{$humgenepos{$tchr}{pos}}; $i++){
		if ( abs($tstart - ${$humgenepos{$tchr}{pos}}[$i]) < $radius){
			$flag=0;
		}
	}
	if ($flag){
		#do something
		return 1;
	} else {
		return 0;
	}
}

# sample from mouse QTLs to see how many are within X of human eQTLs
sub sampledist{
	my ($reps, $radius) = @_;
	my $range = @mouseQTLs;
	#load human gene positions from humgenepos pkg
	load_humQTLs();
	print STDERR "radius is $radius\n";

	for (my $ii=0; $ii<= $reps; $ii++){
		print STDERR "iter $ii\n";
		#my @rands= (undef) x 2700;
		my @rands= (); 
		$#rands = 2699;
		my $sum = 0;
		#create array of 2700 random numbers
		for (my $i=0; $i<2700; $i++){
			#push @rands, int(rand($range));	
			$rands[$i] = int(rand($range));
		}
		print STDERR "size of rands is ",scalar @rands ,"\n";	
		foreach my $k (@rands){
			my ($tchr,$tstart,$tend) = split(/:/,$mouseQTLs[$k]);
			#print "$tchr $tstart $tend\n";
			my $res = is_within_radius($tchr, $tstart,$tend, $radius);
			$sum = $sum + $res;
		}	
		print "$sum\n";
	}
}


# Store the human zero-gene eQTLs
sub load_humQTLs{
	open(INPUT, "uniq_markers300k_zerog_pos.txt") || die "cannot open human zero g file\n";
	while(<INPUT>){
		next if /^#/;
		next if /^M/;
		chomp;
		my @line = split(/\t/);
		#store midpoint of position
		push @{$humzgqtl{$line[0]}{start}},  $line[1];
		push @{$humzgqtl{$line[0]}{stop}},  $line[2];
		#push @{$humzgqtl{$line[0]}{pos}},  round(($line[1]+$line[2])/2);
		#store index 1..235829
		push @{$humzgqtl{$line[0]}{idx}},  $line[3];
	}
	close(INPUT);
	#print Dumper(\%humzgqtl);
}

# for each mouse zerog QTL pos, is there a human zero-gene QTL withiin radius?
sub is_within_radius{
	my ($tchr,$tstart, $tstop, $radius) = @_;

	for (my $i=0; $i < scalar @{$humzgqtl{$tchr}{start}}; $i++){
		if ( abs($tstart - ${$humzgqtl{$tchr}{start}}[$i]) <= $radius){
			return 1;	
		}
	}
	#print mouse marker idx, chr, start, closest hum idx, closest hum pos
	#print "$line[2]\t$tchr\t$tstart\t";
	#print "${$humzgqtl{$tchr}{idx}}[$closest]\t";
	#print "${$humzgqtl{$tchr}{pos}}[$closest]\n";
}
