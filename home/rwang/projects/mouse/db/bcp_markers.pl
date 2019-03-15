#!/usr/bin/perl -w
#use strict;
#
# insert data into markers table
use DBI;

$db = "retention_frequency";
$host = "localhost";
$user = "root";
$password = "smith1";
$table = "markers";

unless (@ARGV) {
	print "$0 <filename>\n";
	exit;
}

#open file
my($fh) = $ARGV[0];
open(INPUT, "$fh") || die "can't open file $fh : $!";

my @table_cols = (
"chromosome",
"chr_index",
"marker",
"copy_0",
"copy_1",
"copy_2",
"alias",
"marker_start",
"marker_end",
"C1",
"C2",
"C3",
"C4",
"C5",
"C6",
"C7",
"C8",
"C9",
"C10",
"C11",
"C12",
"C13",
"C14",
"C15",
"C16",
"C17",
"C18",
"C19",
"C20",
"C21",
"C22",
"C23",
"C24",
"C25",
"C26",
"C27",
"C28",
"C29",
"C30",
"C31",
"C32",
"C33",
"C34",
"C35",
"C36",
"C37",
"C38",
"C39",
"C40",
"C41",
"C42",
"C43",
"C44",
"C45",
"C46",
"C47",
"C48",
"C49",
"C50",
"C51",
"C52",
"C53",
"C54",
"C55",
"C56",
"C57",
"C58",
"C59",
"C60",
"C61",
"C62",
"C63",
"C64",
"C65",
"C66",
"C67",
"C68",
"C69",
"C70",
"C71",
"C72",
"C73",
"C74",
"C75",
"C76",
"C77",
"C78",
"C79",
"C80",
"C81",
"C82",
"C83",
"C84",
"C85",
"C86",
"C87",
"C88",
"C89",
"C90",
"C91",
"C92",
"C93",
"C94",
"C95",
"C96",
"C97",
"C98",
"C99",
"C100",
);

$table_cols = join(',', @table_cols);
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
	($id, $chromosome, $chr_index, $marker, $copy_0, $copy_1, $copy_2, $alias, 
	$marker_start, $marker_end) = split(/,/, $_);

	$sth->execute($id, $probe_set, $stat_pairs, $stat_pairs_used, 
		$signal, $detection, $pval);
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
