#!/usr/bin/perl -w
#
# for each gene, get the distance to the cis ceQTL
use strict;
use lib '/home/rwang/lib';
use DBI;
use mysqldb;
use hummarkerpos;
use Data::Dumper;

sub load_humgenepos_by_index{
	my $sql = "select `index`, chrom, pos_start, pos_end from g3data.ilmn_poshg18 order by `index`";
	my $dbh = db_connect("g3data");	
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $hashref = $sth->fetchall_hashref("index");
	#print Dumper(\$hashref);
	return $hashref;
}

sub find_closest_cis{
	my $hashref = shift;
	open(INPUT, "../cis_FDR40.txt") || die "cannot open cis FDR 40";
	while(<INPUT>){
		next if /^#/; chomp;
		my ($gene, $marker, $alpha, $nlp) = split(/\t/);
		if ($hummarkerpos_by_index{$marker}{chrom} == $hashref->{$gene}{chrom}){
			print $gene,"\t";
			my $gpos = ($hashref->{$gene}{pos_start} + $hashref->{$gene}{pos_end})/2;
			print $gpos,"\t";
			print $marker,"\t";
			print $hummarkerpos_by_index{$marker}{pos},"\t";
			print $alpha,"\t";
			print $nlp,"\n";
		} else {
			#print "cis on different chrom!\n";
		}
	}
}

# load the human marker positions
load_markerpos_by_index("g3data");
my $h = load_humgenepos_by_index();

find_closest_cis($h);
