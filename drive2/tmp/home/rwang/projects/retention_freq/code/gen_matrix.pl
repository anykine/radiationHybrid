#!/usr/bin/perl -w
# 
# generate the matrix of markers against markers with pvalues 
#  later to be imported as heatmap
# make 111 files each of 100 markers x 11084 markers

#homemade library
use lib '/home/rwang/lib';
use util;

use strict;
use DBI;
my($db, $host, $user,$password);
my $sth;

$db = "retention_frequency"; $host = "localhost"; $user = "smithlab";
$password = "smithpass";

#open output
#open conn
my $dbh = DBI->connect("DBI:mysql:database=$db:host=$host",
	$user, $password, {RaiseError=>1}) || die "dberror: ". DBI->errstr . "\n";
my $sql = "SELECT chisq_pval from pvals where marker_1 = ? OR marker_2 = ? ORDER BY marker_2, marker_1";
$sth = $dbh->prepare( $sql) || die "can't prepare query\n";

# do it in a loop for every marker to build 11084x100 table
# $ubound = 11084;
#my $ubound = 100;
for (my $ii=0; $ii<112; $ii++){
	my $filename = "heatmap".$ii.".txt";
	open(OUTPUT, ">$filename");
	for (my $jj=0; $jj<100; $jj++) {
		my $i = (($ii*100)	+ $jj);
		#print "$sql\n";
		$sth->execute($i, $i) || die "can't execute query\n";
		my $counter = 0;
		while (my @data = $sth->fetchrow_array){
			$counter++;
			#print "data=" . $data[0] . "\n";
			print OUTPUT "$data[0]";
			if ($counter == 11084) {
				print OUTPUT "\n";
			} else {
				print OUTPUT ","
			}
		}#while
	}#for
	close(OUTPUT);
}#for

$sth->finish;
close(OUTPUT);
