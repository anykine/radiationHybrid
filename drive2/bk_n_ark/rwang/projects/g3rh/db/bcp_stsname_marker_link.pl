#!/usr/bin/perl -w
#use strict;
#
# insert data into stsname_marker_link table which links
#  sts_info.sts_name with the order of markers in G3pvals
use DBI;

$db = "human_rh";
$host = "localhost";
$user = "root";
$password = "smith1";
$table = "stsname_marker_link";

unless (@ARGV) {
	print "$0 <filename>\n";
	exit;
}

#open file
my($fh) = $ARGV[0];
open(INPUT, "$fh") || die "can't open file $fh : $!";

my @table_cols = (
"sts_name", "m_order"
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
my $i = 1;
while (chomp ($line=<INPUT>))
{
	print "$line $i\n";
	$sth->execute($line, $i);
	$i++;
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
