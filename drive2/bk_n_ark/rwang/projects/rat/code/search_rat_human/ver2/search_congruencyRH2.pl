#!/usr/bin/perl -w
use strict;
#
# PURPOSE: compare RAT T55 with HUMAN G3
#todo: handle errors: no such genes, etc, db null return
#
# search for congruent peaks between rat and mice
# in retention frequency;
# INPUT: rat t31 interaction peaks
# OUTPUT: human G3 markers

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

# this is my data structure
# 100 is the source marker#
#
#100 => {
#	pos => [chr1, 15100000],
#	genes => {
#		USTP => [
#			[chr1, 1010100], pos in organism1
#			[chr17, 54000]   pos in organism2
#		],
#		ARG => [
#			[chr1, 20100100],
#			[chr17, 56000]
#		],
#		GENE3 => [
#			[chr14, 22220],
#			[chr7, 6700000]
#		],
#		GENE77 => [
#			[chr14, 222200],
#			[]  this gene does not exist in organism2
#	},
#	groupedgenes => {
#		1=>[USTP, ARG],   clump close genes together sorted
#		2=>[GENE3]
#	}
#	markers => {
#		1=>{markers=>[marker1401, marker1660], chrom=>17, pos=>[14100, 15000]},
#		2=>{markers=>[marker60, marker62], chrom=>7, pos=>[67000050]}
#	}
#

use DBI;
use Data::Dumper;
use lib '/home/rwang/lib/';
use util;

my $db = "rat_rh";
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
my $sourcemarkers = {};
my @thesehummarkers = ();
my $groupedGenes = [];   #tmp array for clustering of genes
for (my $count =0 ; $count<=$#datafile; $count++){
	print "--startrecord--\n";
	my @data = split(/\t/,$datafile[$count]);
	#do for marker_1 and marker_2
	for (my $count1 = 0; $count1 <2; $count1++){
		my $rec = [];
		$sourcemarkers->{$data[$count1]} = {};
		print Dumper($sourcemarkers);
		print "SOURCE MARKER INPUT: $data[$count1]\n";
		my $valsHashRef;
		getMarker1($data[$count1], $data[$count1], $sourcemarkers, $data[$count1]);
		#print "--main: ret of getRatMarker--\n";
		print Dumper($sourcemarkers);
		#check for err
		#print "--main: call of getRatGene--\n";
		getGene1($sourcemarkers, $data[$count1]);
		#print "--main: ret of getRatGene--\n";
		#print Dumper($ratgenesArrayRef);
		#check for err
		
		#print "--main: call of getHumanGene--\n";
		getGene2($sourcemarkers, $data[$count1]);
		#print "--main: ret of getHumanGene--\n";
		#print Dumper($humangeneHashRef);
		#check for err
		#print mousegene list
		#print "--main: call of getHumanMarker--\n";
		getMarker2($sourcemarkers, $data[$count1]);
		#print "--main: ret of getHumanMarker--\n";
		#print Dumper($humanmarkerHashRef);

		#todo: print human marker list, pos, chrom
		#print "--main: call of getHumanMarkerList--\n";
		#my $humanmarkers = getHumanMarkerList($humanmarkerHashRef);
		#print "--main: ret of getHumanMarkerList--\n";

		#todo: search mouse db, find a way to search output markers;
		#print Dumper($mousemarkers);
#		foreach my $key (keys %$humanmarkers) {
#			if ($count1 == 0) {
#				#first key is array, second key is array of arrays
#				push @{$output{'m1'}}, (${$humanmarkers->{$key}}[0],${$humanmarkers->{$key}}[1]);
#			} else {
#				push @{$output{'m2'}}, [${$humanmarkers->{$key}}[0],${$humanmarkers->{$key}}[1]];
#			}
#		}	
#		#print Dumper(\%output);
#		my $AoAref = searchHumanDB(\%output);
#		extractHumanDB($AoAref);
#		#print Dumper($AoAref);
	}
	#clear marker array and hash
	#print "\nthese rat markers = @theseratmarkers\n";
	#$#theseratmarkers = -1;
	%output = ();
	print "--endrecord--\n\n";
}
#### END MAIN CODE ####

# find pos of markers
# return hashref to hash of lower/upper pos bounds, xsm,err 
	#1. get markerpos, min,max,chrom
sub getMarker1 {
	my($start, $end, $data, $index) = @_;
	my $SQL_GET_LOC_IN_RAT="select a.sts_name,a.m_order,b.trueName,c.chrom,c.chromStart,c.chromEnd from rat_rh.stsname_marker_link a JOIN rat_rh.stsAlias b ON a.sts_name = b.alias JOIN rat_rh.stsMapRat c ON b.trueName = c.name where m_order between ? and ? AND chrom NOT LIKE '%random' and chrom != 'Un'";
	my $sth = $dbh->prepare($SQL_GET_LOC_IN_RAT); 
	$sth->execute($start, $end) || die "cannot execute query\n";

	while (my @seq = $sth->fetchrow_array) {
		$data->{$index}{'pos'} = [$seq[3], $seq[4]];
	}

	print Dumper($data->{$index});
}

# get a list of genes within a region
# returns arrayref to array of array of genes,pos,xsm
	#2. get genes in rat 
sub getGene1 {
	my($data, $index) = @_;
	my $SQL_GET_GENE_RAT = "SELECT a.kgID, a.geneSymbol, b.chrom, b.txStart FROM rat_rh.kgXref a JOIN rat_rh.knownGene b on a.kgID = b.name WHERE b.chrom=? and txStart > ? and txStart < ? AND chrom NOT LIKE '%random' and chrom != 'Un' ORDER by b.txStart";

	#TODO: sometimes alias is better than geneSymbol for looking
	# up corresponding gene in mouse
	# but using this changes the number of columns returned
	#my $SQL_GET_GENE_RAT2 = "SELECT a.kgID, a.geneSymbol, b.chrom, b.txStart, c.alias FROM rat_rh.kgXref a JOIN rat_rh.knownGene b ON a.kgID = b.name JOIN rat_rh.kgAlias c ON a.kgID = c.kgID WHERE b.chrom =? AND txStart >? AND txStart <? ORDER BY b.txStart";
	#print "--in getRatGene--\n";
	#print Dumper($valsRef);

	my $sth = $dbh->prepare($SQL_GET_GENE_RAT); 
	my $chr =  $data->{$index}{'pos'}[0];
	my $pos =  $data->{$index}{'pos'}[1];
	$sth->execute($chr, $pos - 500000, $pos + 500000) || die "cannot execute query\n";
	
	while (my @seq = $sth->fetchrow_array) {
		#ucase to ensure 1 copy of gene
		my $gene = uc($seq[1]);
		#if db returns mult genes w/same name, just pick the first
		next if exists $data->{$index}->{'genes'}{$gene};	
		push @{$data->{$index}->{'genes'}{$gene}}, [$seq[2], $seq[3]];
		print "org1 = @seq\n";
	}
	print "---rat genes---\n";
	print Dumper($data);
}
	
# given list of rat genes, see if such a human gene exist
# return hashref to hash of arrays of arrays where each key is a chrom
#  and each array contains gene, pos, xsm
	#3. get genes in human
sub getGene2{
	my($data, $index) =@_;
	my($where, $listRef) = buildGeneQuery($data, $index);
	#print "where=$where";
	#print Dumper($listRef);
	
	my $SQL_GET_GENE_HUMAN = "select a.kgID, a.geneSymbol, b.chrom, b.txStart from human_rh.kgXref a join human_rh.knownGene b ON a.kgID=b.name	where " . $where . " AND b.chrom NOT LIKE '%random' and b.chrom !='Un' ORDER BY b.chrom, b.txStart";
	my $sth = $dbh->prepare($SQL_GET_GENE_HUMAN); 
	$sth->execute(@$listRef) || die "cannot execute query\n";
	print "org2=@$listRef\n";
	
	while (my @seq = $sth->fetchrow_array) {
		my $gene = uc($seq[1]);
		#some genes map to mult positions, just pick the first one
		unless (@{$data->{$index}{'genes'}{$gene}} == 2) { 
			push @{$data->{$index}->{'genes'}{$gene}}, [$seq[2], $seq[3]];
		}
	}
	print Dumper($data);
}

# given a list of human genes, find closest markers
# returns hashref to hash of array of arrays where each key 
#  is chrom and each array is marker, pos, xsm
	##4. find closest marker to pos in human 
sub getMarker2 {
	my($data, $index) = @_;
	my $SQL_LOC_IN_HUMAN = "SELECT a.chrom, a.chromStart, a.chromEnd,b.trueName, c.sts_name,c.m_order FROM human_rh.stsMap a JOIN human_rh.stsAlias b ON a.name=b.trueName JOIN human_rh.stsname_marker_link c ON b.alias = c.sts_name WHERE a.chrom=? and a.chromStart > ? and a.chromStart < ? order by c.m_order";
	
	#ret ref to hash: min&max for every chrom that a marker resides
	clusterGenes($data, $index);
	#print "debug\n";
	#print Dumper($vals);
	#loop for every chrom, get marker loc
	my $sth = $dbh->prepare($SQL_LOC_IN_HUMAN); 
	my %humanpos = ();
#	foreach my $key (keys %$vals) {
#		#print "${$vals->{$key}}[0]\n";
#		#print "${$vals->{$key}}[1]\n";
#		#print "$key, ${$vals->{$key}}[0], ${$vals->{$key}}[1]\n";
#		$sth->execute($key, ${$vals->{$key}}[0], ${$vals->{$key}}[1]) || die "cannot execute query\n";
#		while (my @seq = $sth->fetchrow_array) {
#			push @{$humanpos{$seq[0]}}, \@seq;	
#		}
#	}
	#print "---human marker pos---\n";
	#print Dumper(\%humanpos);
	return \%humanpos;

}


sub getHumanMarkerList{
	my($humanposHashRef) = @_; 
	#5. get the list of human markers
	my $humanmarkers = getHumanMarkerList2($humanposHashRef);
	#foreach my $key (keys %$mousemarkers) {
	#	print "\nMOUSE OUTPUT: chrom=$key  lowmarker=${$mousemarkers->{$key}}[0] himarker=${$mousemarkers->{$key}}[1]\n";
	#}	
	return $humanmarkers;
}

################################
# Subroutines
# 

# minmax() - rat data
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

#build sql statement to search genes in human 
sub buildGeneQuery {
	my @list=();
	my($data, $index) = @_;
	foreach my $gene (keys %{$data->{$index}{'genes'}}) {
		push @list, $gene;
	}
	my $where = join(" OR ", map {"a.geneSymbol="."?"} @list);
	#print "--in buildGetGeneHuman--\n";
	#print Dumper(\@list);
	#print "where=$where\n";
	return ($where, \@list);

	#for debugging
	#$where = join(" OR ", map {"a.geneSymbol=".$dbh->quote($_)} @list);
	#my $SQL_GET_GENE_HUMAN= "select a.kgID, a.geneSymbol, b.chrom, b.txStart from kgXref a join knownGene b ON a.kgID=b.name	where " . $where . " AND b.chrom NOT LIKE '%random' ORDER BY b.chrom, b.txStart";

	#print "$SQL_GET_GENE_HUMAN\n";
}


# minmax2() - human data
# get min and max of markerpos
# input: hash of array; for each chrom, list of genes and pos 
# output: hash of arrays; for each chrom(gene), min/max locations
# note: some human genes are on diff chromosomes (in rat, same chrom)
# need to get min/max for genes on each chrom (assuming synteny)
sub minmax2 {
	my($hashofarray) = @_;
	my %retval = ();
	my $low = 0;
	my $hi  = 0;
	my $chrom = 0;
	#print "--input of minmax2--\n";
	#print Dumper($hashofarray);

	#some human genes are on diff chromosomes (in rat, same chrom)
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
sub getHumanMarkerList2{
	my($hashofarray) = @_;
	#print "--input getHumanMarkerList2--\n";
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
	#print "--getHumanMarkerList--\n";
	#print Dumper(\%retval);
	return \%retval;
}

sub extractRatGenesList{
	my($arrayref) = @_;
	print "RAT GENE LIST:\n";
	for (my $i=0;$i<=$#$arrayref;$i++){
		print "$arrayref->[$i][1] ";
	}
	print "\n";
}

sub extractHumanGeneList{
	my($HashRef) = @_;
	print "HUMAN GENE LIST:";
	foreach my $key (keys %$HashRef) {
		print "\nchrom$key = ";
		for my $i (@{$HashRef->{$key}}) {
			print "$i->[1] ";
		}
	print "\n";
	}
}

# query humanDB for calculated rat markers
# returns arrayref to array of arrays with mark1, mark2, pval 
sub searchHumanDB{
	my @results = ();
	my($hashrefAoA) = @_;
	my $SQL = "SELECT marker_1, marker_2, chisq_pval FROM human_rh.G3pvals_e06 WHERE (marker_1 between ? and ?) and (marker_2 between ? and ?) order by marker_2, marker_1";
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
sub extractHumanDB{
	my($arrayref) = @_;
	if (@$arrayref) {	
		for(my $i=0; $i<=$#$arrayref; $i++){
			print "marker1= $arrayref->[$i][0]\t";
			print "marker2= $arrayref->[$i][1]\t";
			print "pval= $arrayref->[$i][2]\n";
		}
	}
}

#group genes together that are close together
sub clusterGenes{
	print "call ClusterGenes()\n";
	my($data, $index) = @_;
	my $BINSIZE = 100000;
	my %tmp = (); #hash of genes per chrom
	foreach my $key (keys %{$data->{$index}{'genes'}}){
		#if this gene is found in Organism2 and Organism1
		if ( @{$data->{$index}{'genes'}{$key}} == 2) {
			#print $key, $data->{$index}{'genes'}{$key}[1][0], "\n";
			#build tmp datastruct indexed by chromosome
			push @{$tmp{$data->{$index}{'genes'}{$key}[1][0]}}, [$key,
				$data->{$index}{'genes'}{$key}[1][1] ];
		}
	}
	print Dumper(\%tmp);
	#sort
	my @sorted=(); #sorted list of genes on chrom
	#for every chrom, sort genes by bp pos
	foreach my $key (keys %tmp){
		@sorted = sort {$a->[1] <=> $b->[1]} @{$tmp{$key}};
	}
	print "sorted tmp datastruct\n";
	print Dumper(\@sorted);
	#cluster based on distance between ends
	#remove from ends and create new clusters as needed
	my($stdev, $avg) = AoAStdev(\@sorted);
	print "stdev= $stdev\n";
	while ($sorted[$#sorted][1] - $sorted[0][1] > $BINSIZE) {
		if (abs($sorted[$#sorted][1]-$stdev) > abs($sorted[0][1]-$stdev)){
			#kludgy classifier
			#pop off the back
			my $aref = splice(@sorted, $#sorted,1 );
			my $bin = ($aref->[1] - $stdev)/$BINSIZE;
			print "1bin= $bin gene= $aref->[0] bp= $aref->[1]\n";
			print Dumper(\@sorted);
			#handleLeftOvers($aref, $groupedGenes, $bin);
			#push $newgroups[$counter], [$aref];
		} else {
			#pop off the front 
			my $aref = splice(@sorted, 0,1 );
			my $bin = ($aref->[1] - $stdev)/$BINSIZE;
			print "2bin= $bin gene= $aref->[0] bp= $aref->[1]\n";
			#handleLeftOvers($aref, $groupedGenes, $bin);
			#push $newgroups[$counter], [$aref];
		}
	}
	print "sorted array\n";
	print Dumper(\@sorted);
	exit;
}
#array of array of arrayrefs [ [ref1,ref2],[ref3,ref4] ]
sub handleLeftOvers{
	my($aref, $groupedGenes, $bin) = @_;
	print "arrayref--->\n";
	print Dumper($aref);
	my $arrsize = @{$groupedGenes};
	if ($arrsize == 0) {
		print "adding to new array you should see this 1x\n";
		push @{$groupedGenes}, [[@{$aref}]]; 
	} else {
		#i'm going to need to iterate
		#push @{$groupedGenes->[0]}, ['test', 123]; 
		print "before push\n";
		print Dumper($groupedGenes);
		my $size1= scalar@{$groupedGenes}; my $size2=scalar@{$groupedGenes->[0]};
		print "size1= $size1 size2=$size2\n";
		#print "size1= $#$groupedGenes size2=$#{$groupedGenes->[0]}\n";
		for (my $i=0; $i<=$#$groupedGenes; $i++){
			#for (my $j=0; $j< $#{$groupedGenes->[0]} ;$j++) {
			#within 1MB
			if (abs($groupedGenes->[$i][0][1] -  $aref->[1]) < 1000000){
				print "add to existing array\n";
				#only 1 entry in array, so must be before/after
				if (@{$groupedGenes->[0]} == 1) {
					print "only 1 entry in array, adding another one\n";
					if ($aref->[1] > $groupedGenes->[0][1] ) {
						push @{$groupedGenes->[$i]}, [@{$aref}]; 
					} else {
						unshift @{$groupedGenes->[$i]}, [@{$aref}]; 
					}
				}else {
					#decide to push before, between, after
					#iterate
					for(my $j=0; $j<=$#{$groupedGenes->[$i]}; $j++){

					}
				}
				push @{$groupedGenes->[$i]}, [@{$aref}]; 
				next;
				#do something clever to sort
			} else {
				print "add to new array\n";
				push @{$groupedGenes->[$i+1]}, [@{$aref}];
				#push onto new array
				next;
			}#if
		}#for
	}

	print "groupgenes--->\n";
	print Dumper($groupedGenes);
}

sub AoAStdev{
	my ($aref) = @_;
	my $avg = AoASum($aref)/($#$aref+1);
	my @output = map{($_->[1] - $avg)**2 } @{$aref};
	my $sos = arraySum(\@output);
	my $stdev = $sos/($#$aref+1);
	return (sqrt($stdev), $avg);
}

sub arraySum{
	my($aref)=@_;
	my $sum=0;
	for (my $i=0; $i<=$#$aref; $i++) {$sum += $aref->[$i];}
	return $sum;
}
sub AoASum{
	my($aref) = @_;
	my $sum=0;
	for (my $i=0; $i<=$#$aref; $i++) {$sum += $aref->[$i][1];}
	return $sum;
}
#this rounds both pos/neg numbers
sub round {
	my($number) = shift;
	return int($number + .5 * ($number <=> 0));
}
