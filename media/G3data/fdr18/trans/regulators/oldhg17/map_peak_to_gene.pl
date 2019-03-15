#!/usr/bin/perl -w
#
use strict;
use DBI;
# map trans peak marker to closest gene
# you can then do GO analysis on those peaks

#if you wanna display on UCSC genome browser need BED format
#chrN start stop name ....
my $BED = 0;

my %markers=();
my $dbh = db_connect();
load_markers();
#search

print "track name=\"CGH Markers\" description=\"CGH Markers\"\n" if $BED==1;
# i=marker number [0, 235829]
foreach my $i (keys %markers){
	my($sym,$def,$ont,$chr,$start,$stop) =find_closest_gene($i, $dbh);
	if ($BED==1){
		print "chr$chr\t$start\t$stop\t$i" 
	} else {
		#marker num | closest gene symbol | num genes regulated
		#print "$i\t$sym\t$markers{$i}\n";
		print "$sym\t$markers{$i}\n";
	}
}

# for a marker id, find the closest gene for a marker
sub find_closest_gene{
	my($markerid, $dbh) = @_;
	my($aref, $closestidx,$diff,$probename);
	$closestidx = 0;
	#lookup markerpos
	my $sql1 = "select a.chrom,a.pos_start,a.pos_end from 
		g3data.agil_poshg18 a where a.index=? order by a.pos_start";
	my $sth=$dbh->prepare($sql1);
	$sth->execute($markerid);
	my($chr,$start,$stop)=$sth->fetchrow_array();
	#print "$chr $start $stop\n";

	#lookup genes on chrom=$chr
	my $sql2 = "select a.probename,a.pos_start,a.pos_end,a.index from 
		ilmn_poshg18 a where a.chrom=? order by a.pos_start";
	$sth = $dbh->prepare($sql2);
	$sth->execute($chr);
	#return an array, iterate to find closest gene pos 
	$aref = $sth->fetchall_arrayref();
	#set closestidx to first record, find closest
	$closestidx = $aref->[0]->[3];
	#set it to something big
	$diff = 10000000; 
	foreach my $i (@$aref){
		if (abs($i->[1] - $start) < $diff){
			#store the index
			$closestidx = $i->[3];
			$diff = abs($i->[1] - $start);
			$probename = $i->[0];
		}
	}
	#now we have the closest gene to marker of interest
	my $sql3 = "select a.symbol,a.definition,a.ontology 
		from human_rh.ilmn_ref8 a where Target=? limit 0,1";
	$sth = $dbh->prepare($sql3);
	#this is the probename from the search
	$sth->execute($probename);
	my($sym,$def,$ont) = $sth->fetchrow_array();
	#print "[$sym\t$def\t$ont]\n";
	# return gene info, and marker position
	return($sym,$def,$ont,$chr,$start,$stop);
}

sub db_connect{
	my $dbh = DBI->connect("DBI:mysql:database=g3data:host=localhost",
		"root", "smith1", {RaiseError=>1}) or die "dberror: ".DBI->errstr;
	return $dbh;
}

# file format is marker ID | pos | num genes it regulates
sub load_markers{
	open(INPUT, "/media/G3data/fdr/trans/genes_reg_markers/genes_reg_by_markers_sortbynum.txt") || die "cannot open file1\n";
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		#store marker ID, num genes regulated
		$markers{$data[0]}  = $data[2];
	}
}
