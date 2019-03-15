#!/usr/bin/perl -w
#use strict;
#
# insert data into pvals table
use DBI;

$db = "retention_frequency";
$host = "localhost";
$user = "root";
$password = "smith1";
$table = "counts";

unless (@ARGV) {
	print "$0 <filename>\n";
	exit;
}

#open file
my($fh) = $ARGV[0];
open(INPUT, "$fh") || die "can't open file $fh : $!";

my @table_cols = (
"bothpres", "onepresoneabs", "oneabsonepres", "bothabs", "marker_1", "marker_2"
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
	@ar1 = split(/\t/, $_);
	#$ar1[1] contains pval
	@ar2 = split(/ /, $ar1[3]);
	$marker1 = $ar2[1]*1;
	$marker1 = $marker1 + 1;
	$marker2 = $ar2[2]*1;
	$marker2 = $marker2 + 1;
	print "$ar1[0],$ar1[1], $ar1[2], $ar2[0], $marker1, $marker2\n";
	$sth->execute($ar1[0],$ar1[1], $ar1[2], $ar2[0], $marker1, $marker2);
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
