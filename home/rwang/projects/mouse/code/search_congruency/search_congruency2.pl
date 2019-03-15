#!/usr/bin/perl -w
use strict;
#
#todo: handle errors: no such genes, etc, db null return
#
# search for congruent peaks between human and mice
# in retention frequency;
# INPUT: human G3 interaction peaks
# OUTPUT: mouse G3 markers

#things I've learned in this: 
# 1. if you return a hash from a subroutine, you're just
# passing back a list of strings, but if you assign
# it to a hash as the return val of your subroutine
# it converts it to a hash. This is because you can 
# initialize a hash as a list of string values like so:
# %hash = "key value key value";
# this gives the appearance that you're returning a hash
# but in reality you are not, you're initializing a new
# hash with a bunch of string values;
#
# 2. in a sub, you really need to use my($var)=@_ otherwise
# it won't work as expected (i.e. my $var=@_ is NOT equivalent)
use DBI;
use Data::Dumper;
use lib '/home/rwang/lib/';
use util;

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
my @datafile = get_file_data($fh);

#open conn
my $dbh = DBI->connect("DBI:mysql:database=$db:host=$host",
	$user, $password, {RaiseError=>1}) || die "dberror: ". DBI->errstr;

#### MAIN CODE ####
my %output = ();
my @thesehummarkers = ();
my @thesemousemarkers = ();
for (my $count =0 ; $count<=$#datafile; $count++){
	print "--startrecord--\n";
	my @data = split(/\t/,$datafile[$count]);
	#do for marker_1 and marker_2
	for (my $count1 = 0; $count1 <2; $count1++){
		push @thesehummarkers, $data[$count1];
		#print "--main: call of getHumanMarker--\n";
		print "HUM MARKER INPUT: $data[$count1]\n";
		my $valsHashRef = getHumanMarker($data[$count1], $data[$count1]);
		#print "--main: ret of getHumanMarker--\n";
		#print Dumper($valsHashRef);
		if ($valsHashRef->{err}) {
			#skip to next of val pair
			next;
		}
		print "HUM MARKER LOC chrom=$valsHashRef->{chrom} low=$valsHashRef->{low} hi=$valsHashRef->{hi}\n";
		#print "--main: call of getHumanGene--\n";
		my $humgenesArrayRef = getHumanGene($valsHashRef);
		#print "--main: ret of getHumanGene--\n";
		#print Dumper($humgenesArrayRef);
		unless (@$humgenesArrayRef){
			next;
		}
		#print human genes list
		extractHumanGenesList($humgenesArrayRef);	
		
		#print "--main: call of getMouseGene--\n";
		my $mousegeneHashRef = getMouseGene($humgenesArrayRef);
		#print "--main: ret of getMouseGene--\n";
		#print Dumper($mousegeneHashRef);
		unless (keys %$mousegeneHashRef) {
			next;
		}
		#print mousegene list
		extractMouseGeneList($mousegeneHashRef);
		#print "--main: call of getMouseMarker--\n";
		my $mousemarkerHashRef = getMouseMarker($mousegeneHashRef);
		#print "--main: ret of getMouseMarker--\n";
		#print Dumper($mousemarkerHashRef);
		unless (keys %$mousemarkerHashRef) {
			next;
		}
		#todo: print mouse marker list, pos, chrom
		#print "--main: call of getMouseMarkerList--\n";
		my $mousemarkers = getMouseMarkerList($mousemarkerHashRef);
		#print "--main: ret of getMouseMarkerList--\n";

		#todo: search mouse db, find a way to search output markers;
		#print Dumper($mousemarkers);
		foreach my $key (keys %$mousemarkers) {
			if ($count1 == 0) {
				#first key is array, second key is array of arrays
				push @{$output{'m1'}}, (${$mousemarkers->{$key}}[0],${$mousemarkers->{$key}}[1]);
			} else {
				push @{$output{'m2'}}, [${$mousemarkers->{$key}}[0],${$mousemarkers->{$key}}[1]];
			}
		}	
		#print Dumper(\%output);
		my $AoAref = searchMouseDB(\%output);
		extractMouseDB($AoAref);
		#print Dumper($AoAref);
	}
	#clear marker array and hash
	print "\nthese human markers = @thesehummarkers\n";
	$#thesehummarkers = -1;
	%output = ();
	print "--endrecord--\n\n";
}
#### END MAIN CODE ####

# find pos of markers
# return hashref to hash of lower/upper pos bounds, xsm,err 
sub getHumanMarker {
	my($start, $end) = @_;
	my @humpos= ();
	my $SQL_GET_LOC_IN_HUMAN="select a.sts_name,a.m_order,b.trueName,c.chrom,c.chromStart,c.chromEnd from human_rh.stsname_marker_link a JOIN human_rh.stsAlias b ON a.sts_name = b.alias JOIN stsMap c ON b.trueName = c.name where m_order between ? and ?";
	my $sth = $dbh->prepare($SQL_GET_LOC_IN_HUMAN); 
	$sth->execute($start, $end) || die "cannot execute query\n";

	#1. get markerpos, min,max,chrom
	while (my @seq = $sth->fetchrow_array) {
		#create an array of arrays [[a,b,c],[d,e,f]]
		push @humpos, \@seq;
	}

	#print "---human marker pos---\n";
	#print Dumper(@humpos);
	#print "max is $#humpos\n";
	#get min/max bp for markers
	my $valsRef = minmax(\@humpos, $#humpos);
	#print "---in get human gene marker ---\n";
	#print Dumper($valsRef);
	#print "$valsRef->{chrom} $valsRef->{low} $valsRef->{hi}\n";
	return $valsRef;
}

# get a list of genes within a region
# returns arrayref to array of array of genes,pos,xsm
sub getHumanGene {
	my($valsRef) = @_;
	my $SQL_GET_GENE_HUMAN = "SELECT a.kgID, a.geneSymbol, b.chrom, b.txStart FROM human_rh.kgXref a JOIN human_rh.knownGene b on a.kgID = b.name WHERE b.chrom=? and txStart > ? and txStart < ? ORDER by b.txStart";

	#print "--in getHumanGene--\n";
	#print Dumper($valsRef);

	#2. get genes in human
	my $sth = $dbh->prepare($SQL_GET_GENE_HUMAN); 
	$sth->execute($valsRef->{chrom}, $valsRef->{low}, $valsRef->{hi}) || die "cannot execute query\n";
	
	my @humgenes = ();
	while (my @seq = $sth->fetchrow_array) {
		push @humgenes, \@seq;
		#print "@seq\n";
	}
	#print "---human genes---\n";
	#print Dumper(@humgenes);
	return \@humgenes;	
}
	
# no longer used 
sub changeToMouseDB {
	## CHANGE DATABASE to mouse##
	my $sth = $dbh->prepare("USE retention_frequency");
	$sth->execute() || die "cannot execute query\n";
}

# given list of human genes, see if such a mouse gene exist
# return hashref to hash of arrays of arrays where each key is a chrom
#  and each array contains gene, pos, xsm
sub getMouseGene {
	my($humgenesArrayRef) =@_;
	#3. get genes in mouse
	my($where, $listRef) = buildGetGeneMouse($humgenesArrayRef);
	#print "--in getMouseGene--\n";
	#print "where=$where";
	#print Dumper($listRef);
	
	my $SQL_GET_GENE_MOUSE = "select a.kgID, a.geneSymbol, b.chrom, b.txStart from retention_frequency.kgXref a join retention_frequency.knownGene b ON a.kgID=b.name	where " . $where . " AND b.chrom NOT LIKE '%random' ORDER BY b.chrom, b.txStart";
	my $sth = $dbh->prepare($SQL_GET_GENE_MOUSE); 
	$sth->execute(@$listRef) || die "cannot execute query\n";
	#print "@$list\n";
	
	my %mousegenes = ();
	while (my @seq = $sth->fetchrow_array) {
		#create hash of arrays where key is chrom and each array is for a diff gene
		#push @{$mousegenes{'1'}}, \@seq;	
		push @{$mousegenes{$seq[2]}}, \@seq;	
	}
	#print "---mouse genes---\n";
	#print Dumper(\%mousegenes);
	#print "$mousegenes{19}->[0][2]\n";
	return \%mousegenes;
}

# given a list of mouse genes, find closest markers
# returns hashref to hash of array of arrays where each key 
#  is chrom and each array is marker, pos, xsm
sub getMouseMarker {
	my($mousegenesHashRef) = @_;
	##4. find closest marker to pos in mouse
	my $SQL_LOC_IN_MOUSE = "SELECT a.chrom, a.chromStart, a.chromEnd,c.marker, c.id,d.m_order FROM retention_frequency.stsMapMouseNew a JOIN retention_frequency.stsAlias b ON a.name=b.trueName JOIN retention_frequency.markers c ON b.alias = c.marker JOIN retention_frequency.marker_pval_link d ON c.id=d.marker_id WHERE a.chrom=? and a.chromStart > ? and a.chromStart < ? order by d.m_order";
	
	#ret ref to hash: min&max for every chrom that a marker resides
	my $vals = minmax2($mousegenesHashRef);
	#print "debug\n";
	#print Dumper($vals);
	#loop for every chrom, get marker loc
	my $sth = $dbh->prepare($SQL_LOC_IN_MOUSE); 
	my %mousepos = ();
	foreach my $key (keys %$vals) {
		#print "${$vals->{$key}}[0]\n";
		#print "${$vals->{$key}}[1]\n";
		#print "$key, ${$vals->{$key}}[0], ${$vals->{$key}}[1]\n";
		$sth->execute($key, ${$vals->{$key}}[0], ${$vals->{$key}}[1]) || die "cannot execute query\n";
		while (my @seq = $sth->fetchrow_array) {
			push @{$mousepos{$seq[0]}}, \@seq;	
		}
	}
	#print "---mouse marker pos---\n";
	#print Dumper(\%mousepos);
	return \%mousepos;

}


sub getMouseMarkerList{
	my($mouseposHashRef) = @_; 
	#5. get the list of mouse markers
	my $mousemarkers = getMouseMarkerList2($mouseposHashRef);
	#foreach my $key (keys %$mousemarkers) {
	#	print "\nMOUSE OUTPUT: chrom=$key  lowmarker=${$mousemarkers->{$key}}[0] himarker=${$mousemarkers->{$key}}[1]\n";
	#}	
	return $mousemarkers;
}

################################
# Subroutines
# 

# minmax() - human data
# get min and max of markerpos
# input: arrayref and last index of array
# note: array indices are columns of SQL statement
sub minmax {
	my($arrayref,$max) = @_;
	#print "--in minmax() $max--\n";
	#print Dumper(@$arrayref);
	my %retval = ();
	my $low = $arrayref->[0][4];
	my $hi  = $arrayref->[0][5];
	my $err = 0;
	my $chrom = $arrayref->[0][3];
	for (my $i=1; $i<=$max; $i++){
		if ($arrayref->[$i][4] < $low) {
			$low=$arrayref->[$i][4];
		}
		if ($arrayref->[$i][5] > $hi) {
			$hi=$arrayref->[$i][5];
		}
		if ($arrayref->[$i][3] ne $chrom) {
			$err = 1;
			#break out of loop
			print "*marker not on same chromosome: $arrayref->[$i][0]\n";
			last;
		}
	}
	if (($low - 500000) > 0) {
		$low = $low - 500000;
	} else {
		$low = $low;
	}
	#need to get chrom maxsizes
	$hi = $hi + 500000;
	#can add +/- distance to high and low values to increase
	#search radius
	%retval = (
		low => $low,
		hi  => $hi,
		chrom => $chrom,
		err => $err
	);
	return \%retval;
}

#build sql statement to search genes in mouse
sub buildGetGeneMouse {
	my $counter;
	my @list=();
	my($genelistRef) = @_;
	# $#$genelistRef is the last index of array pointed to by genelistRef
	#print "buildGetGeneMouse max: $#$genelistRef\n";
	for (my $i=0;$i<=$#$genelistRef;$i++){
		push @list, $genelistRef->[$i][1];
	}
	my $where = join(" OR ", map {"a.geneSymbol="."?"} @list);
	#print "--in buildGetGeneMouse--\n";
	#print Dumper(\@list);
	#print "where=$where\n";
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
	#print "--input of minmax2--\n";
	#print Dumper($hashofarray);

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
	#print "--output minmax2--\n";
	#print Dumper(\%retval);
	return \%retval;
}

#get the marker list low/hi from hash of arrays
# indexed by chrom
sub getMouseMarkerList2{
	my($hashofarray) = @_;
	#print "--input getMouseMarkerList2--\n";
	#print Dumper($hashofarray);
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

sub extractHumanGenesList{
	my($arrayref) = @_;
	print "HUM GENE LIST:\n";
	for (my $i=0;$i<=$#$arrayref;$i++){
		print "$arrayref->[$i][1] ";
	}
	print "\n";
}

sub extractMouseGeneList{
	my($HashRef) = @_;
	print "MOUSE GENE LIST:";
	foreach my $key (keys %$HashRef) {
		print "\nchrom$key = ";
		for my $i (@{$HashRef->{$key}}) {
			print "$i->[1] ";
		}
	print "\n";
	}
}

# query mouseDB for calculated mouse markers
# returns arrayref to array of arrays with mark1, mark2, pval 
sub searchMouseDB{
	my @results = ();
	my($hashrefAoA) = @_;
	my $SQL = "SELECT marker_1, marker_2, chisq_pval FROM retention_frequency.pvals_e06 WHERE (marker_1 between ? and ?) and (marker_2 between ? and ?) order by marker_2, marker_1";
	my $sth = $dbh->prepare($SQL); 

	#must have both keys
	if (exists $hashrefAoA->{'m1'}){
		if (exists $hashrefAoA->{'m2'}) {
			foreach my $i(@{$hashrefAoA->{'m2'}}){
				#print "hashrefAoA=";
				#print "$i->[0]\n"	;
				#print "m1=$hashrefAoA->{'m1'}[0]\n";
				#work out order, which is first, second
				if (($i->[0]) < ($hashrefAoA->{'m1'}[0])) {
					$sth->execute($i->[0],$i->[1],$hashrefAoA->{'m1'}[0],$hashrefAoA->{'m1'}[1]) || die "cannot execute query\n";
				} else {
					$sth->execute($hashrefAoA->{'m1'}[0],$hashrefAoA->{'m1'}[1],$i->[0],$i->[1]) || die "cannot execute query\n";
				}
				while (my @seq = $sth->fetchrow_array) {
					push @results, \@seq;
				}#while
			}#foreach
		}
	}
	return \@results;	
}

#db returns recordset, stored as array of arrays
#extract and print
sub extractMouseDB{
	my($arrayref) = @_;
	if (@$arrayref) {	
		for(my $i=0; $i<=$#$arrayref; $i++){
			print "marker1= $arrayref->[$i][0]\t";
			print "marker2= $arrayref->[$i][1]\t";
			print "pval= $arrayref->[$i][2]\n";
		}
	}
}
