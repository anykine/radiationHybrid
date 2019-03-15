#!/usr/bin/perl -w

# remove from a database table those entries that
# appear in a file

use strict;
use DBI;
use lib '/home/rwang/lib/';
use util;
our $dbh;

unless (@ARGV == 1) {
	print <<EOH;
	usage: $0 <file to read> 

	Remove from a particular database table those
	entries that appear in specified file. For instance,
	removing those genes in a table that are specified in 
	an input file.
EOH
exit(0);
}
open_db_conn();
my @data = get_file_data($ARGV[0]);
del_from_table_by_array(\@data);


### SUBROUTINES ###
sub open_db_conn{
	my $db = "test";
	my $db_host = "localhost";
	my $db_user = "root";
	my $db_pass = "smith1";
	$dbh = DBI->connect("DBI:mysql:database=$db:host=$db_host",
	$db_user, $db_pass, {RaiseError=>1}) or die "dberror: ".DBI->errstr;
}
#input is an arrayref
sub del_from_table_by_array{
	my $arrayref = shift;
	my $sql = "delete from ilmn_genes_reduced where ilmn_gene= ?";
	my $sth = $dbh->prepare($sql);
	foreach my $i (@$arrayref) {
		next if $i =~ /^#/;
		my @data = split(/\t/, $i);
		$sth->execute($data[0]);
	}
}
sub query_db2file{
	#get the probe, write a fasta file
	my($gene) = @_;
	my @files = ();
	#remove * at end of genename; append wildcard 
	$gene =~ s/\*$//;
	$gene .= '%';
	#print "sql gene is $gene\n";
	my $sql = "select a.genbank_accession, a.unigene_symbol,a.probename, b.probe 
			from agilent_array a join agilent_probe b on a.probename = b.probename
			where unigene_symbol like ?";
	my $count = 0;
	my $sth = $dbh->prepare($sql);
	$sth->execute($gene);

	while (my($acc, $unigene, $pname, $probe) = $sth->fetchrow_array()) {
		#print "$acc $unigene\n";
		my $file = lc($unigene) ."+$pname" . '.txt';
		my $filepath = './probefiles/'.$file;
		#print "file to be written: $file\n";
		#store the file FYI
		push @files, $file;
		#gene file may have already been written 
		next if (-e $filepath); 
		open OUTPUT, ">$filepath";
		print OUTPUT ">$acc|$unigene|$pname", "\n";
		print OUTPUT "$probe";
		close OUTPUT;
		$count++	
	}
	return @files;
}

