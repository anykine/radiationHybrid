#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;
use DBI;
use lib '/home/rwang/lib/';
use mysqldb;
use humgenepos;

#we import %humgenepos and %hummarkerpos
my %genepos=();
my %markerpos = ();

sub usage() {
	print <<EOH;
	Given a list of gene-marker peaks, find peaks that are at least
	RADIUS away from a known gene. These are 0-gene eQTL peaks.
	
	usage $0 <threshold peak file> 
		$0  trans_peaks_FDR40.txt
		$0 /media/G3data/mm7tohg18/markers/liftover10/mus_hg18_pos_coordonly.txt
EOH
exit(1);
}

# UNUSED
# should I use UCSC gene coords?
sub read_gene_coords{
	my $file = shift;
	my $idx = 1;
	open(INPUT, "/home3/rwang/QTL_comp/g3gene_gc_coordshg18.txt") || die "cannot open gene pos file\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		$genepos{$idx} = $_;
		$idx++;
	}
	#print Dumper(\%genepos);
}

# UNUSED
sub read_marker_coords{
	my $file = shift;
	my $idx = 1;
	open(INPUT, "/home3/rwang/QTL_comp/g3probe_gc_coords.txt") || die "cannot open gene pos file\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		$markerpos{$idx} = $_;
		$idx++;
	}
	#print Dumper(\%genepos);
}


#nonoptimal - read FDR40 file and find those markers further than 
# 300kb away from a known gene
sub find_zero_gene_peaks{
	my $file = shift;
	my $radius = 300000;
	my $flag;
	my $sql = "select `index`,chrom,round((pos_start+pos_end)/2) from g3data.agil_poshg18 where `index`=?";
	my $dbh = db_connect("g3data");
	my $sth = $dbh->prepare($sql);
	open(INPUT, $file) || die "cannot open peaks file\n";
	#file format gene|marker|alpha|nlp
	while(<INPUT>){
		next if /^#/; 
		chomp;
		my @line = split(/\t/);
		#get position of marker
		$sth->execute( $line[1] ) ;
		my @rs = $sth->fetchrow_array();
		$flag = 1;
		#print "***checking marker $rs[0] at pos $rs[1] : $rs[2]\n";
		#search gene hash for gene within RADIUS
		for (my $i=0; $i< scalar @{$humgenepos{$rs[1]}{pos}}; $i++){
			#print ${$humgenepos{$rs[1]}}[$i], "\n";
			if ( abs($rs[2] - ${$humgenepos{$rs[1]}{pos}}[$i]) < $radius ){
				#print "\tinside for $i\n";
				$flag = 0;
				last;
			}
		}
		if ($flag) {
			#print "\t\tOUTSIDE ";
			print join("\t", @line),"\n";
		}
	}
}

# are the mouse zero gene eQTL's (300kb radius) still zero gene eQTLs in human?
sub check_mouse_eqtl_human{
	my $file = shift;
	my %mousetransl = ();
	my $flag ;
	my $radius = 300000;
	open(INPUT, $file) || die "cannot open liftover file\n";
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

	open(INPUT, "./mouse/0_gene_300k_trans_4.0.txt") || die "can't open zero gene mouse stuff\n";
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
		for (my $i=0; $i < scalar @{$humgenepos{$tchr}{pos}}; $i++){
			if ( abs($tstart - ${$humgenepos{$tchr}{pos}}[$i]) < $radius ){
				$flag = 0;
			}
		}
		if ($flag){
			print join("\t", @line), "\n";
		}
	}
}

########## MAIN ##############33
unless (@ARGV ==1 ){
	usage();
}

# find zero gene peaks using ILMN
#load_genepos_from_db("g3data");
#find_zero_gene_peaks($ARGV[0]);

# find zero gene peaks using UCSC 
load_genepos_from_dbucsc("ucschg18");
find_zero_gene_peaks($ARGV[0]);

# are translated zero-gene eQTLs from mouse still > 300kb in human?
#load_genepos_from_dbucsc("ucschg18");
#check_mouse_eqtl_human($ARGV[0]);

# UNUSED routines
#load_markerpos_from_db("g3data");
#read_gene_coords();
#read_marker_coords();
