#!/usr/bin/perl -w

#get the vectors out of the database in chromosomal, positional order
#and output to file
use strict;
use DBI;

my $i;
my($db, $host, $user, $password, $sth);
$db = "human_rh"; $host = "localhost"; $user = "smithlab"; $password = "smithpass";

my $dbh = DBI->connect("DBI:mysql:database=$db:host=$host",
	$user, $password, {RaiseError=>1}) || die "dberror: ". DBI->errstr . "\n";

my $sql = "SELECT G3_hybrid_scores FROM sts_info a JOIN stsAlias b ON a.sts_name=b.alias JOIN stsMap c ON b.trueName = c.name WHERE G3_hybrid_scores != '' AND c.chrom = ? AND chrom not like '%random' ORDER BY chrom, chromStart";

$sth = $dbh->prepare($sql) || die "can't prepare query\n";

my %chroms = (1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7, 8,8,  9,9, 10,10, 11,11, 12,12, 13,13,
	14,14, 15,15, 16,16, 17,17, 18,18, 19,19, 20,20, 21,21, 22,22, "X","X", "Y","Y");

my $filename = "g3output_all.txt";
open(OUTPUT, ">$filename");
foreach my $key (sort keys %chroms) {
	$sth->execute($key) || die "can't execute query\n";
	while (my @data = $sth->fetchrow_array){
		print OUTPUT "@data\n";
	}
	#print "$key $chroms{$key} \n";
}
close(OUTPUT);

#for ($i=1; $i<23; $i++){
#	my $filename = "g3output_".$i.".txt";
#	open(OUTPUT, ">$filename");
#	$sth->execute($i) || die "can't execute query\n";
#	while (my @data = $sth->fetchrow_array){
#		print OUTPUT "@data\n";
#	}
#	close(OUTPUT);
#}
