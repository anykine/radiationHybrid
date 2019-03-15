#!/usr/bin/perl -w
#
# see if a microRNA is close to any of my zero gene 
use strict;
use lib '/home/rwang/lib';
use mysqldb;
use DBI;
use Data::Dumper;

my %microRNA=();

#load microRNA position data;
sub load_microRNA_pos{
	
	my $sql =  "select chrom, chromStart, chromEnd from ucschg18.wgRna2 
	where type='miRna' order by chrom,chromStart";
	my $dbh = db_connect("ucschg18");	
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array()){
		push @{$microRNA{$rs[0]}{start}}, $rs[1];
		push @{$microRNA{$rs[0]}{stop}}, $rs[2];
	}
	#print Dumper(\%microRNA);
}

my %zgpos=();

# load the zero gene positions
# currently using all zero-gene peaks NOT filtered by 1mb radius
sub load_zerogene_pos{
	# individ markers
	#open(INPUT, "uniq_markers300k_zerog_pos.txt") || die "cannot open zg file\n";	
	# clustered markers
	open(INPUT, "./unique/zero_gene_peaks_uniq_pos.txt") || die "cannot open zg file\n";	
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		push @{$zgpos{$data[2]}{start}}, $data[3];
		push @{$zgpos{$data[2]}{end}}, $data[4];
	}
	#print Dumper(\%zgpos);
}

# strategy: for each marker, find the distance closest zerogene cluster
sub miRNA_dist_to_zerogene{

	# microRNAs are short, assume pointwise
	# for each microRNA chr
	foreach my $chr(keys %microRNA){
		# for each miRNA
		for (my $j=0; $j< scalar @{$microRNA{$chr}{start}}; $j++){
			#search each zerogene on that chrom
			my $closest = 0;
			for (my $zg=0; $zg < scalar @{$zgpos{$chr}{start}}; $zg++ ){
				if (abs(${$zgpos{$chr}{start}}[$zg]-${$microRNA{$chr}{start}}[$j]) < 
				 abs(${$zgpos{$chr}{start}}[$closest]-${$microRNA{$chr}{start}}[$j]) )  {

					$closest = $zg;
				}
				#print $j,"\n";
			}
			print "$chr\t$microRNA{$chr}{start}[$j]\t$zgpos{$chr}{start}[$closest]\n";
		}
	}
}

######## MAIN #############
load_microRNA_pos();
load_zerogene_pos();
miRNA_dist_to_zerogene()
