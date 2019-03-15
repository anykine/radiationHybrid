#!/usr/bin/perl -w
# 
# get all markers along a chromosome and pvals

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

my $sql = "SELECT marker_1, marker_2, chisq_pval, chromosome, marker_start, marker_id FROM pvals p JOIN marker_pval_link j ON p.marker_1+1 = j.m_order JOIN markers m ON j.marker_id = m.id WHERE marker_2=5600 AND m.chromosome=? ORDER BY m.chromosome,m.marker_start";

$sth = $dbh->prepare( $sql) || die "can't prepare query\n";

for (my $i=1; $i<21; $i++){
	my $filename = "chrompval".$i.".txt";
	open(OUTPUT, ">$filename");
		#print "$sql\n";
		$sth->execute($i) || die "can't execute query\n";
		while (my @data = $sth->fetchrow_array){
			#print "data=" . $data[0] . "\n";
			print OUTPUT "@data\n";
		}#while
	close(OUTPUT);
}#for

$sth->finish;
close(OUTPUT);
