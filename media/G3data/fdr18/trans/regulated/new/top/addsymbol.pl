#!/usr/bin/perl -w
#
#add the gene symbol to the gene index (human)
use strict;
use DBI;
use Data::Dumper;

my $dbh = DBI->connect('DBI:mysql:g3data', 'root', 'smith1') || die "cannot connect to db";
my $sql = "select `index`, symbol from g3data.ilmn_sym order by `index`";
my $sth = $dbh->prepare($sql);
$sth->execute();
my $result = $sth->fetchall_hashref('index');

open(INPUT, "top100_FDR40.txt") || die "cannot open top100 file\n";
while(<INPUT>){
	chomp; next if /^#/;
	my @d = split(/\t/);
	print $result->{$d[0]}{symbol},"\t";
	print join("\t", @d), "\n";
}
