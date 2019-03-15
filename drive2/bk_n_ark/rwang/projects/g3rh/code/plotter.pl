#!/usr/bin/perl -w
#use strict;
#
# select a marker against a chromosome and get its pvalues
# you can then plot it in R
# 
# input: marker# chromosome#
use DBI;

$db = "human_rh";
$host = "localhost";
$user = "smithlab";
$password = "smithpass";

unless ($ARGV[0] && $ARGV[1]) {
	print "$0 <marker#> <chromosome#>\n";
	exit;
}

$sql1= "select a.marker_1, a.marker_2, a.chisq_pval, d.chrom, d.chromStart FROM G3pvals a JOIN stsname_marker_link b ON a.marker_1 = b.m_order JOIN stsAlias c ON b.sts_name = c.alias JOIN stsMap d ON c.trueName = d.name WHERE marker_2 = ? AND chrom=? AND chrom NOT like '%random' ORDER BY chrom, chromStart, marker_2, marker_1";
$sql2 = "select a.marker_1, a.marker_2, a.chisq_pval, d.chrom, d.chromStart FROM G3pvals a JOIN stsname_marker_link b on a.marker_2= b.m_order JOIN stsAlias c on b.sts_name = c.alias JOIN stsMap d ON c.trueName = d.name WHERE marker_1 = ? AND chrom=? AND chrom NOT like '%random' ORDER BY chrom, chromStart, marker_2, marker_1";

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
	print "$marker1\t$marker2\t$chisq\t$chr\t$mark_start\n";
}
foreach my $a (@$data2){
	my($marker1,$marker2,$chisq,$chr,$mark_start) = @$a;
	print "$marker1\t$marker2\t$chisq\t$chr\t$mark_start\n";
}
