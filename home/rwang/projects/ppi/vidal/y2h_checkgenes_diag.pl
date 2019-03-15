#!/usr/bin/perl -w

# 9/7/06 Richard Wang
#
# Vidal 2005 paper - diagnostic program
# 
# check list of genes(entrez Gene) for names on agilent 
# microarray (UniGene)
#
use strict;
use Data::Dumper;
use DBI;
my $host = "localhost"; 
my $user = "root"; 
my $password = "smith1";
my $db = "ppi";
my $sqlarraylist = "select * from agilentarray where name=?";
my $sqlaliaslist = "select symbol from gene_aliases where alias=?";
my $seen = 0;

my $dbh= DBI->connect("DBI:mysql:database=$db:host=$host", 
	$user, $password, {RaiseError=>1}) || die "dberror: ".DBI->errstr;

my @data = ();
open(INPUT, $ARGV[0]) or die "cannot open file\n";

while(<INPUT>){
	my($id1,$gene1,$id2,$gene2,$y2h) = split(/,/)	;

	if ($y2h =~ /\+/){
		push @data, [$gene1, $gene2];
	}
}
#print Dumper(\@data);
print "size of data array is " . scalar @data . "\n";

my %datahash = ();
for (my $i=0; $i<=$#data; $i++){
	for (my $j=0; $j<=1; $j++){
		if (defined $datahash{${$data[$i]}[$j]}) {
			$datahash{${$data[$i]}[$j]}++; 
		} else {
			$datahash{${$data[$i]}[$j]} = 1; 
		}
	}
}
print "size of hash is" . keys(%datahash) . "\n";
print Dumper(\%datahash);
my $sum =0;
while (my ($k, $v) = each %datahash) {
	$sum += $v;	
}
print "Sum = $sum\n";
