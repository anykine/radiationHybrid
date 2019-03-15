#!/usr/bin/perl -w
#use strict;
#
# insert data into pvals table
use DBI;

$db = "retention_frequency";
$host = "localhost";
$user = "root";
$password = "smith1";
$table = "pvals";

unless (@ARGV) {
	print "$0 <filename>\n";
	exit;
}

#open file
my($fh) = $ARGV[0];
open(INPUT, "$fh") || die "can't open file $fh : $!";

my @table_cols = (
"marker_1", "marker_2", "chisq_pval"
);

$table_cols = join(',', @table_cols);
#make the right number of questionmarks
my $qm = "";
for (my $k=0; $k<=$#table_cols; $k++) {
	if ($k == $#table_cols) {
		$qm = $qm . "?";
	}else {
		$qm = $qm . "?,"; 
	}
}
#print "$qm\n\n";
#open conn
my $dbh = DBI->connect("DBI:mysql:database=$db:host=$host",
	$user, $password, {RaiseError=>1}) || die "dberror: ". DBI->errstr;

my $sth = $dbh->prepare( "INSERT INTO $table ($table_cols) VALUES ($qm)");

#read in file and put in array
while (<INPUT>)
{
	@ar1 = split(/:/, $_);
	#$ar1[1] contains pval
	@ar2 = split(/ /, $ar1[0]);
	@ar3  = split(/=/, $ar2[0]);
	@ar3a = split(/=/, $ar2[1]);
	print "$ar3[1],$ar3a[1], $ar1[1]\n";
	$sth->execute($ar3[1],$ar3a[1], $ar1[1]);
}
close INPUT;



############################
# SUBS
############################
sub strip_quote{
	my($var) = @_;
	$var =~ s/"//g;
	#$var =~ s/^/"/g;
	#$var =~ s/$/"/g; 
return $var;
}
