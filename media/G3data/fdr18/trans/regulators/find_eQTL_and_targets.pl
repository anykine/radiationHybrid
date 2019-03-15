#!/usr/bin/perl -w
#
# Find the gene closest to peak marker (the eQTL).
# For this regulator, find the genes that it affects.
#
# input is markerID and number of genes it regulates
use strict;
use Data::Dumper;
use DBI;

unless (@ARGV==1){
	print <<EOH;
	$0 <file to read in>
	 eg $0 genes_reg_by_markers_sortbynum.txt
	
	file format is markerID|pos|num genes reg by marker
	
	Output the data as gene nearest peak marker and the genes
	that are regulated.
EOH
exit(1);
}
# the markers regulating most genes
# markerid | num genes it regulates
my %highest2=(
	145844=> 1143,
	75242=>  1144,
	145846=> 1146,
	145845=> 1147,
	100637=> 1149,
	100638=> 1150,
	100705=> 1150,
	100665=> 1153,
	224459=> 1160,
	75240=>  1164
);
#store highest, read from file
my %highest=();
#store genes regulated by each marker
my %ghash = ();

load_highest($ARGV[0]);
my $dbh = db_connect();
find_regulated_genes();
find_gene_names($dbh);

#input marker_id , gene id
# find marker's position
#  search gene list for closest gene
#  report gene and distance
#
#  ALSO
#  given gene id, find gene name 
sub find_gene_names{
	my ($dbh) = @_;
	my $sql = "select b.Symbol from g3data.ilmn_poshg18 a join
	 human_rh.ilmn_ref8 b on a.probename=b.Target where a.index=?";
	my $sth = $dbh->prepare($sql);
	#for loop over all genes of a marker
	for my $i (keys %ghash){
		#find the nearest gene for $i
		my($sym,$def,$ont) = find_closest_gene($i, $dbh);
		print "*marker $i regulates ", scalar @{$ghash{$i}}, " genes [";
		print $sym,"\t" if defined $sym;
		print $def,"\t" if defined $def;
		print $ont if defined $ont;
		print "]\n\n";

		foreach my $j (@{$ghash{$i}}) {
			$sth->execute($j);
			my($data) = $sth->fetchrow_array();
			print "\t$data\n";
		}
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
	return($sym,$def,$ont);
}

#extract genes from file
sub find_regulated_genes{
	open(INPUT, "trans2.4bymarker.txt") || die "cannot open file 1\n";
	#open(INPUT, "test.in") || die "cannot open file 1\n";
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		for my $i (keys %highest){
			#skip if i found max number of genes
			if (defined $ghash{$i} ){
				next if scalar @{$ghash{$i}} == $highest{$i};
			}
			if ($data[1] == $i){
				push @{$ghash{$i}}, $data[0];
			}
		}
	}
	#print Dumper(\%ghash);
}

sub db_connect{
	my $dbh = DBI->connect("DBI:mysql:database=g3data:host=localhost",
		"root", "smith1", {RaiseError=>1}) or die "dberror: ".DBI->errstr;
	return $dbh;
}

# file format is marker ID | pos | num genes it regulates
sub load_highest{
	my($file) = @_;
	open(INPUT, $file) || die "cannot open file of high vals\n";
	while(<INPUT>){
		my @data = split(/\t/);
		#store marker ID, num genes regulated
		$highest{ $data[0] }  = $data[2];
	}
}
