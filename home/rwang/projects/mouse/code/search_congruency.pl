#!/usr/bin/perl -w
use strict;
#
#todo: handle errors: no such genes, etc, db null return
#
# search for congruent peaks between human and mice
# in retention frequency;
# INPUT: human G3 interaction peaks
# OUTPUT: mouse G3 markers
use DBI;
use Data::Dumper;

my $db = "human_rh";
my $host = "localhost";
my $user = "root";
my $password = "smith1";
unless (@ARGV) {
	print "$0 <input filename>\n";
	exit;
}

#open file
my($fh) = $ARGV[0];
open(INPUT, "$fh") || die "can't open file $fh : $!";

my $SQL_GET_LOC_IN_HUMAN="select a.sts_name,a.m_order,b.trueName,c.chrom,c.chromStart,c.chromEnd from stsname_marker_link a JOIN stsAlias b ON a.sts_name = b.alias JOIN stsMap c ON b.trueName = c.name where m_order between ? and ?";
#open conn
my $dbh = DBI->connect("DBI:mysql:database=$db:host=$host",
	$user, $password, {RaiseError=>1}) || die "dberror: ". DBI->errstr;
my $sth = $dbh->prepare($SQL_GET_LOC_IN_HUMAN); 
$sth->execute($ARGV[1], $ARGV[1]) || die "cannot execute query\n";

#1. get markerpos, min,max,chrom
my @humpos= ();
while (my @seq = $sth->fetchrow_array) {
	#create an array of array [[a,b,c],[d,e,f]]
	push @humpos, \@seq;
}

print "---human marker pos---\n";
print Dumper(@humpos);
#print "max is $#humpos\n";
my %vals = minmax(\@humpos, $#humpos);
print "$vals{chrom} $vals{low} $vals{hi}\n";

my $SQL_GET_GENE_HUMAN = "SELECT a.kgID, a.geneSymbol, b.chrom, b.txStart FROM `kgXref` a JOIN knownGene b on a.kgID = b.name WHERE b.chrom=? and txStart > ? and txStart < ? ORDER by b.txStart";

#2. get genes in human
$sth = $dbh->prepare($SQL_GET_GENE_HUMAN); 
$sth->execute($vals{chrom}, $vals{low}, $vals{hi}) || die "cannot execute query\n";

my @humgenes = ();
while (my @seq = $sth->fetchrow_array) {
	push @humgenes, \@seq;
	#print "@seq\n";
}
print "---human genes---\n";
print Dumper(@humgenes);

## CHANGE DATABASE to mouse##
$sth = $dbh->prepare("USE retention_frequency");
$sth->execute() || die "cannot execute query\n";

#3. get genes in mouse
my($where, $list) = buildGetGeneMouse(\@humgenes,$#humgenes);

my $SQL_GET_GENE_MOUSE = "select a.kgID, a.geneSymbol, b.chrom, b.txStart from kgXref a join knownGene b ON a.kgID=b.name	where " . $where . " AND b.chrom NOT LIKE '%random' ORDER BY b.chrom, b.txStart";
$sth = $dbh->prepare($SQL_GET_GENE_MOUSE); 
$sth->execute(@$list) || die "cannot execute query\n";
#print "@$list\n";

my %mousegenes = ();
while (my @seq = $sth->fetchrow_array) {
	#create hash of arrays where key is chrom and each array is for a diff gene
	#push @{$mousegenes{'1'}}, \@seq;	
	push @{$mousegenes{$seq[2]}}, \@seq;	
}
print "---mouse genes---\n";
print Dumper(\%mousegenes);
#print "$mousegenes{19}->[0][2]\n";

##4. find closest marker to pos in mouse
my $SQL_LOC_IN_MOUSE = "SELECT a.chrom, a.chromStart, a.chromEnd,c.marker, c.id,d.m_order FROM `stsMapMouseNew` a JOIN stsAlias b ON a.name=b.trueName JOIN markers c ON b.alias = c.marker JOIN marker_pval_link d ON c.id=d.marker_id WHERE a.chrom=? and a.chromStart > ? and a.chromStart < ? order by d.m_order";

#ret ref to hash: min&max for every chrom that a marker resides
my $vals = minmax2(\%mousegenes);
#print "debug\n";
#print Dumper($vals);
#loop for every chrom, get marker loc
$sth = $dbh->prepare($SQL_LOC_IN_MOUSE); 
my %mousepos = ();
foreach my $key (keys %$vals) {
	#print "${$vals->{$key}}[0]\n";
	#print "${$vals->{$key}}[1]\n";
	print "$key, ${$vals->{$key}}[0], ${$vals->{$key}}[1]\n";
	$sth->execute($key, ${$vals->{$key}}[0], ${$vals->{$key}}[1]) || die "cannot execute query\n";
	while (my @seq = $sth->fetchrow_array) {
		push @{$mousepos{$seq[0]}}, \@seq;	
	}
}
print "---mouse marker pos---\n";
print Dumper(\%mousepos);

#5. get the list of mouse markers
my $mousemarkers = getMouseMarkerList(\%mousepos);
foreach my $key (keys %$mousemarkers) {
	print "chrom=$key  hi=${$mousemarkers->{$key}}[0] low=${$mousemarkers->{$key}}[1]\n";
}	

################################
# Subroutines
# 

# minmax() - human data
# get min and max of markerpos
# input: arrayref and last index of array
sub minmax {
	my($array,$max) = @_;
	#print Dumper(@$array);
	my %retval = ();
	my $low = $array->[0][4];
	my $hi  = $array->[0][5];
	my $err = 0;
	my $chrom = $array->[0][3];
	for (my $i=1; $i<=$max; $i++){
		if ($array->[$i][4] < $low) {
			$low=$array->[$i][4];
		}
		if ($array->[$i][5] > $hi) {
			$hi=$array->[$i][5];
		}
		if ($array->[$i][3] ne $chrom) {
			$err = 1;
			#break out of loop
			print "marker not on same chromosome: $array->[$i][0]\n";
			last;
		}
	}
	$low = $low - 500000;
	$hi = $hi + 500000;
	#can add +/- distance to high and low values to increase
	#search radius
	%retval = (
		low => $low,
		hi  => $hi,
		chrom => $chrom,
		err => $err
	);
	return %retval;
}

#build sql statement to search genes in mouse
sub buildGetGeneMouse {
	my @list=();
	my($genelist,$max) = @_;

	for (my $i=0;$i<=$max;$i++){
		push @list, $genelist->[$i][1];
	}
	my $where = join(" OR ", map {"a.geneSymbol="."?"} @list);
	return ($where, \@list);

	#for debugging
	#$where = join(" OR ", map {"a.geneSymbol=".$dbh->quote($_)} @list);
	#my $SQL_GET_GENE_MOUSE = "select a.kgID, a.geneSymbol, b.chrom, b.txStart from kgXref a join knownGene b ON a.kgID=b.name	where " . $where . " AND b.chrom NOT LIKE '%random' ORDER BY b.chrom, b.txStart";

	#print "$SQL_GET_GENE_MOUSE\n";
}


# minmax2() - mouse data
# get min and max of markerpos
# input: hash of array; for each chrom, list of genes and pos 
# output: hash of arrays; for each chrom(gene), min/max locations
# note: some mouse genes are on diff chromosomes (in human, same chrom)
# need to get min/max for genes on each chrom (assuming synteny)
sub minmax2 {
	my($hashofarray) = @_;
	my %retval = ();
	my $low = 0;
	my $hi  = 0;
	my $chrom = 0;
	#print "$hashofarray->{'19'}[0][2]\n";
	#print Dumper($hashofarray);
	#print "\n";
	#some mouse genes are on diff chromosomes (in human, same chrom)
	# need to get min/max for genes on each chrom (assuming synteny)
	foreach my $key (keys %$hashofarray) {
		$low = $hashofarray->{$key}[0][3];
		$hi  = $hashofarray->{$key}[0][3];
		for my $i (@{$hashofarray->{$key}}) {
			if ($i->[3] < $low) {
				$low=$i->[3];
			}
			if ($i->[3] > $hi) {
				$hi=$i->[3];
			}
		}
		#print "key=$key low=$low high=$hi\n";
		$low = $low-1000000;
		$hi = $hi+1000000;
		#return hash of arrays where key is chrom, array is [low,hi]
		$retval{$key} = [$low, $hi];
	}
	#print Dumper(\%retval);
	return \%retval;
}

#get the marker list low/hi from hash of arrays
# indexed by chrom
sub getMouseMarkerList{
	my($hashofarray) = @_;
	#print Dumper(@$array);
	my %retval = ();
	my $low = 0;
	my $hi  = 0;
	my $chrom = 0;
	foreach my $key (keys %$hashofarray) {
		$low=$hashofarray->{$key}[0][5];
		$hi =$hashofarray->{$key}[0][5];
		for my $i (@{$hashofarray->{$key}}) {
			if ($i->[5] < $low) {
				$low=$i->[5];
			}
			if ($i->[5] > $hi) {
				$hi=$i->[5];
			}
		}
	#print "key=$key low=$low high=$hi\n";
	$retval{$key} = [$low, $hi];
	}
	#print "--getMouseMarkerList--\n";
	#print Dumper(\%retval);
	return \%retval;
}
