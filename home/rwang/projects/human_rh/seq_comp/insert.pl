#!/usr/bin/perl -w
#
#
use strict;
use DBI;

my $dbh=DBI->connect("DBI:mysql:database=human_rh:host=localhost", "root","smith1", {RaiseError=>1}) or die "dberror: ".DBI->errstr;
my $sth = $dbh->prepare("insert into ilmn_ref8syn1(probeID,symbol,synonym) value(?,?,?)");
open(INPUT, "sql.out") || die "cannot open file for read\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	$sth->execute($line[0], $line[1], $line[1]);
}
