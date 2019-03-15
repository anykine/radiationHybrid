#!/usr/bin/perl -w
#use strict;
#
# select a marker against a chromosome and get its pvalues
# you can then plot it in R automatically
# 
# input: marker# chromosome#
use DBI;
use R;
use RReferences;
use strict;
use warnings;
use Data::Dumper;

my $db = "retention_frequency";
my $host = "localhost";
my $user = "root";
my $password = "smith1";

unless ($ARGV[0] && $ARGV[1]) {
	print "$0 <marker#> <chromosome#>\n";
	exit;
}

my $sql1= "select marker_1, marker_2, chisq_pval, chromosome, marker_start from pvals p join marker_pval_link j on p.marker_1+1 = j.m_order join markers m on j.marker_id = m.id where marker_2 = ? AND chromosome=? order by chromosome, marker_start, marker_2, marker_1";
my $sql2 = "select marker_1, marker_2, chisq_pval, chromosome, marker_start from pvals p join marker_pval_link j on p.marker_2+1= j.m_order join markers m on j.marker_id = m.id where marker_1 = ? AND marker_1 != marker_2 AND chromosome=? order by chromosome, marker_start, marker_2, marker_1";

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
#arrays of x, y values to plot
my @yvals = ();
my @xvals = ();
my $i=0;
foreach my $a (@$data1){
	my($marker1,$marker2,$chisq,$chr,$mark_start) = @$a;
	#print "$marker1,$marker2,$chisq,$chr,$mark_start\n";
	$yvals[$i] = $chisq;
	$xvals[$i] = $mark_start;
	$i++;
}
foreach my $a (@$data2){
	my($marker1,$marker2,$chisq,$chr,$mark_start) = @$a;
	#print "$marker1,$marker2,$chisq,$chr,$mark_start\n";
	$yvals[$i] = $chisq;
	$xvals[$i] = $mark_start;
	$i++;
}

&R::initR("--silent");
&R::library("RSPerl");
&R::callWithNames("plot", {'x',\@xvals,'y',\@yvals});

sleep(10);
