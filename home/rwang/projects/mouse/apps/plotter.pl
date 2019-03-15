#!/usr/bin/perl -w
#use strict;
#
# select a marker against a chromosome and get its pvalues
# you can then plot it in R
# 
# input: marker# chromosome#
use DBI;

$db = "retention_frequency";
$host = "localhost";
$user = "root";
$password = "smith1";

unless ($ARGV[0] && $ARGV[1]) {
	print "$0 <marker#> <chromosome#>\n";
	exit;
}

$sql1= "select marker_1, marker_2, chisq_pval, chromosome, marker_start from pvals p join marker_pval_link j on p.marker_1+1 = j.m_order join markers m on j.marker_id = m.id where marker_2 = ? AND chromosome=? order by chromosome, marker_start, marker_2, marker_1";
$sql2 = "select marker_1, marker_2, chisq_pval, chromosome, marker_start from pvals p join marker_pval_link j on p.marker_2+1= j.m_order join markers m on j.marker_id = m.id where marker_1 = ? AND marker_1 != marker_2 AND chromosome=? order by chromosome, marker_start, marker_2, marker_1";

#open conn
my $dbh = DBI->connect("DBI:mysql:database=$db:host=$host",
	$user, $password, {RaiseError=>1}) || die "dberror: ". DBI->errstr;

#execute once, twice;
my $sth = $dbh->prepare($sql1);
$sth->execute($ARGV[0], $ARGV[1]);
my $data1 = $sth->fetchall_arrayref();
$sth->finish();
$sth = $dbh->prepare($sql2);
$sth->execute($ARGV[0], $ARGV[1]);
my $data2 = $sth->fetchall_arrayref();

$dbh->disconnect();

foreach my $a (@$data1){
	my($marker1,$marker2,$chisq,$chr,$mark_start) = @$a;
	print "$marker1,$marker2,$chisq,$chr,$mark_start\n";
}
foreach my $a (@$data2){
	my($marker1,$marker2,$chisq,$chr,$mark_start) = @$a;
	print "$marker1,$marker2,$chisq,$chr,$mark_start\n";
}
