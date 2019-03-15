#!/usr/bin/perl -w
use strict;
#
# insert arraydata into arraydata table
use DBI;

my $db = "retention_frequency";
my $host = "localhost";
my $user = "root";
my $password = "smith1";

unless (@ARGV) {
	print "$0 <filename>\n";
	exit;
}

#open file
my($fh) = $ARGV[0];
open(INPUT, "$fh") || die "can't open file $fh : $!";


#open conn
my $dbh = DBI->connect("DBI:mysql:database=$db:host=$host",
	$user, $password, {RaiseError=>1}) || die "dberror: ". DBI->errstr;

my $sel_sth = $dbh->prepare("SELECT * from markers");
$sel_sth->execute();
my @row =$sel_sth->fetchrow_array();
$sel_sth->finish();
foreach my $key (keys %$href) {
	print "$key\n";
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
