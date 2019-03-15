#!/usr/bin/perl -w
# make files, one for each chrom, of markers in order
# 
use DBI;

$sqlmarkers = "SELECT g3_hybrid_scores from allg3_final1 where Chrom=? order by Chrom, chromStart";
my($db,$hist,$user,$password,$sth);
$db="human_rh"; $host="localhost";$user="smithlab";$password="smithpass";
my $dbh=DBI->connect("DBI:mysql:database=$db:host=$host",
	$user,$password,{RaiseError=>1}) || die "dberror: ".DBI->errstr;

$sth = $dbh->prepare($sqlmarkers);
for (my $i=1; $i<25; $i++){
	my $filename = "rh_genotype_chr" . $i . ".txt";
	open(OUTPUT, ">$filename") || die "cannot open file for output\n";
	$sth->execute($i);
	while (my @data = $sth->fetchrow_array() ) {
		print OUTPUT "$data[0]\n";			
	}
	close(OUTPUT);
}
