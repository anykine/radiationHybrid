#!/usr/bin/perl -w
#
# This builds a table of mouse zero gene blocks AND
#  overlapping lincRNA (Lander), new gene (wold), microRNA, hum zero gene blocks
#  just for information purposes
use strict;
use Data::Dumper;

my %mouse=();

# create the mouse table
sub init{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k.txt") || 
	 die "cannot open mouse 0gene peak file";
	while(<INPUT>){
		#mousekey is chrom/start/stop separated by tabs
		chomp; next if /^#/;
		my(undef,$chrom,$start,undef,undef,$stop) = split(/\t/);
		my $key = join("\t", $chrom,$start,$stop);
		$mouse{$key}{lincRNA} = 0;
		$mouse{$key}{wold} = 0;
		$mouse{$key}{miRNA} = 0;
		$mouse{$key}{human} = 0;
	}
	close(INPUT);
#print Dumper(\%mouse);
}

# look at mouse-linc
# Read in a mus_<something> comparision file
# inputs: 
#  - hashfield: linc/wold/miRNA /human
#  - hash description of file format
sub add_comparison{
	my($file, $hashfield, $aref) = @_;
	#print Dumper($aref); 
	open(INPUT, $file) || die "cannot open file";
	while(<INPUT>){
		next if /^#/; chomp;
		my @d = split(/\t/);
		my $key = join("\t", $d[$aref->{mchrom}], $d[$aref->{mstart}], $d[$aref->{mstop}]);
		#print $key,"\n";
		if (defined $mouse{$key}){
			$mouse{$key}{$hashfield}++;
		}
	}
}

sub output{
	#print Dumper(\%mouse);
	foreach my $k (keys %mouse){
		print join("\t",$k,$mouse{$k}{lincRNA},
		$mouse{$k}{wold},
		$mouse{$k}{miRNA}),"\n";
	}
}

############ MAIN ##################
init();
add_comparison("20090330mus_lincRNA_overlap.txt",
	"lincRNA",
	{mchrom=>0, mstart=>1, mstop=>2}
);
add_comparison("20090330mus_wold_overlap.txt",
	"wold",
	{mchrom=>0, mstart=>1, mstop=>2}
);
add_comparison("20090403mus_mirbase_overlap.txt",
	"miRNA",
	{mchrom=>0, mstart=>1, mstop=>2}
);
output();
