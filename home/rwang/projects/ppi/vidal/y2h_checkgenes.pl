#!/usr/bin/perl -w

# 9/7/06 Richard Wang
#
# Vidal 2005 paper
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

my $sth = $dbh->prepare($sqlarraylist);
for (my $i=0; $i<=$#data; $i++){
	print "${$data[$i]}[0]\t${$data[$i]}[1]\n";
	for (my $j=0; $j<= 1; $j++){
		$sth->execute( ${$data[$i]}[$j] );
		my @dbdata = $sth->fetchrow_array;
		#dbi returns empty list if no match,
		#check size of array to see if empty
		if (@dbdata) {
			print "dbfound: $dbdata[0]\n";
			$seen++;
		} else{
			#gene name not found in microarray list, get an alias
			# and check again
			my $sth1 = $dbh->prepare($sqlaliaslist);
			$sth1->execute( ${$data[$i]}[$j] );
			my @alias = $sth1->fetchrow_array;
			if (@alias) {
				#check if this is in microarray list
				$sth->execute( $alias[0] );
				my @aliasquery = $sth->fetchrow_array;
				if (@aliasquery) {
					print "i found a replacement! it's $alias[0]\n";
					$seen++;
					#replace entry in arry of arrays
					${$data[$i]}[$j] = $alias[0];
				}
			}
		}
	}#for
	print "${$data[$i]}[0]\t${$data[$i]}[1]\n";
}#for
print "seen = $seen\n";

print "---------cuthere---------\n";
#build a hash of interactions
my %interactions = ();
for (my $i=0; $i<=$#data; $i++){
	if (exists $interactions{${$data[$i]}[0]}){
		my $tmp = join(" ", @{$interactions{${$data[$i]}[0]}} );
		print "tmpval = $tmp\n";
		print "interactor = ${$data[$i]}[1]\n";
		if ($tmp =~ /${$data[$i]}[1]}/i){
			print "already present\n";
		} else {
			push @{$interactions{${$data[$i]}[0]}}, ${$data[$i]}[1];
		}
	} else {
		push @{$interactions{${$data[$i]}[0]}}, ${$data[$i]}[1];
	}
}
#print Dumper(\%interactions);
open(OUTPUT, ">y2h_vidal_interactions.txt") or die "cannot open file\n";
#count num interactions
my $counter=0;
for my $key (keys %interactions){
	$counter += scalar @{$interactions{$key}};
	print OUTPUT "$key ";
	print OUTPUT "@{$interactions{$key}}", "\n";
}
print "num interactions=$counter\n";


