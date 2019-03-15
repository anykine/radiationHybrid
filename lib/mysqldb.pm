package mysqldb;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&db_connect);
use strict;
use warnings;
use DBI;

# pass in databasename
sub db_connect{
	my $db = shift;
	my $dbh = DBI->connect("DBI:mysql:database=" . $db . ":host=localhost", 
		"root", "smith1", {RaiseError=>1}) or die "dberror: " . DBI->errstr;
		return $dbh;
}

1;

=head1 NAME

mysqldb - universal connect to MySQL database

=head1 SYNOPSIS

 #to connect just do
 db_connect("name of database")

=head1 AUTHOR

Richard Wang

