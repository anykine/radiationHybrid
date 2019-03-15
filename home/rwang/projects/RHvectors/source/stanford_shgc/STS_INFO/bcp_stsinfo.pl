#!/usr/bin/perl -w
#use strict;
#
# insert data into pvals table
use DBI;

$db = "human_rh";
$host = "localhost";
$user = "root";
$password = "smith1";
$table = "sts_info2";

unless (@ARGV) {
	print "$0 <filename>\n";
	exit;
}

#open file
my($fh) = $ARGV[0];
open(INPUT, "$fh") || die "can't open file $fh : $!";

my @table_cols = (
	"sts_name",
	"chromosome",
	"starting_material" ,
	"genbank_src" ,
	"genbank_acc_no" ,
	"unists" ,
	"product_size" ,
	"fwd_primer_seq" ,
	"rev_primer_seq" ,	
	"full_seq",
	"cDNA_or_not" ,
	"TNG_hybrid_scores" ,
	"G3_hybrid_scores" 
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
print "$qm\n\n";
#open conn
my $dbh = DBI->connect("DBI:mysql:database=$db:host=$host",
	$user, $password, {RaiseError=>1}) || die "dberror: ". DBI->errstr;

my $sth = $dbh->prepare( "INSERT INTO $table ($table_cols) VALUES ($qm)");

#read in file and put in array
while (<INPUT>)
{
	@ar = split(/\t/, $_);
	print "tot=$#ar\n";
	$ar[1] =~ s/\s+//g;
	print "$ar[0],
	$ar[1],
	$ar[2],
	$ar[3],
	$ar[4],
	$ar[5],
	$ar[6],
	$ar[7],
	$ar[8],
	$ar[9],
	$ar[10],
	$ar[12],
	$ar[13]
	\n ";
#column 11 is of type unknown
	$sth->execute($ar[0],
	$ar[1],
	$ar[2],
	$ar[3],
	$ar[4],
	$ar[5],
	$ar[6],
	$ar[7],
	$ar[8],
	$ar[9],
	$ar[10],
	$ar[12],
	$ar[13]
	);
}
close INPUT;



############################
sub strip_quote{
	my($var) = @_;
	$var =~ s/"//g;
	#$var =~ s/^/"/g;
	#$var =~ s/$/"/g; 
return $var;
}
