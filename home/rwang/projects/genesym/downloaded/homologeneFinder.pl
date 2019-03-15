#!/usr/bin/perl -w

use strict;
use DBI;
use Data::Dumper;
use lib '/home/rwang/lib';
use util;

unless (@ARGV ==1){
	print <<EOH;
	This program reads in a file of ILMN probeID,refseq accesion,symbol
	and tries to find the matching data from AGIL.

	usage $0 <ilmn_file_input>
	  e.g. $0 	ilmn_probe_acc.txt.parsed

EOH
exit(0);
}
our $dbh;
my @file = get_file_data($ARGV[0]);
open_db_conn();

foreach my $i(@file){
	chomp($i);
	#cols: probeid,refseq acc,symbol
	my @data = split(/\t/,$i);
	#print "--starting with @data\n";
	my @symbols_by_acc= query_ncbi($data[1]);
	#print "sizeof symbolarray=",scalar @symbols_by_acc,"\n";
	if (@symbols_by_acc == 0){
		#print "crapping\n";
		next;
	}
	#print_array(\@symbols_by_acc);	
	my @refseqs = query_kgAlias(@symbols_by_acc);
	#print "sizeof refseq array=",scalar @refseqs,"\n";
	if (@refseqs == 0){
		#print "crapping2\n";
		next;
	}
	#print_array(\@refseqs);	
	my @geneids = query_refseq(@refseqs);	
	#print "sizeof geneids array=",scalar @geneids,"\n";
	if (@geneids ==0){
		#print "crapping3\n";
		next;
	}
	#print_array(\@geneids);
	my @mouseaccessions = query_geneID(@geneids);
	#print "sizeof mouseaccession array=", scalar @mouseaccessions, "\n";
	if (@mouseaccessions ==0){
		#print "crapping4\n";
		next;
	}
	#print_array(\@mouseaccessions);
	my %mousegenes = query_agil(@mouseaccessions);

	#output results
	my @keys = keys %mousegenes;
	foreach my $i (@keys){
		#HUMAN probe, gene MOUSE probe gene
		print "$data[0]\t$data[2]\t$i\t$mousegenes{$i}\n";
	}
}

# get HUMAN gene symbol for a given accesssion (ILMN)
sub query_ncbi{
	my $acc = shift;
	my @records = ();
	my $sql = "select distinct symbol from ncbi.gene_id_refseq a JOIN ncbi.gene_id_symbol b on a.geneID=b.geneID where accession=?";
	my $sth = $dbh->prepare($sql);
	$sth->execute($acc);
	while(my($symbol) = $sth->fetchrow_array()){
		#print "$symbol\n";
		#print "rec\n" if $symbol !~ /join(" ", @records)/;
		push @records, $symbol if $symbol !~ /join(" ", @records)/;
	}
	return @records;
}
# get a set of refseq accession that have a given symbol in MOUSE
sub query_kgAlias{
	my @symbols = @_;
	return 0 if (@symbols == 0);
	my @records = ();
	my $sql = "select b.refSeq from ucscmm8.kgAlias a join ucscmm8.kgXref b on a.kgID=b.kgID where a.alias=?";
	my $sth=$dbh->prepare($sql);
	foreach my $i (@symbols){
		$sth->execute($i);
		while(my($refseq) = $sth->fetchrow_array()){
			next if $refseq eq '';
			push @records, $refseq if join(' ', @records) !~ /$refseq/ig ;
			#push @records, $refseq if ($refseq !~ /join(' ', @records)/ig)  ;
		}
	}
	return @records;
}
# get a set of geneIDs for a given refseq accession 
sub query_refseq{
	my @refseqs = @_;
	return 0 if (@refseqs == 0);
	my @records = ();
	my $sql="select a.geneID from ncbi.gene_id_refseq a join ncbi.gene_id_symbol b on a.geneID=b.geneID where accession=?";
	my $sth=$dbh->prepare($sql);
	foreach my $i (@refseqs){
		$sth->execute($i);
		while( my($geneID) = $sth->fetchrow_array()){
			next if $geneID eq '';
			push @records, $geneID if join(' ',@records) !~ /$geneID/ig;
		}
	}
	return @records;
}
# get all accessions for a given geneID
sub query_geneID{
	my @geneids = @_;
	return 0 if (@geneids == 0);
	my @records=();
	my $sql="select a.accession from ncbi.gene_id_refseq a join ncbi.gene_id_symbol b on a.geneID=b.geneID where a.geneID=?";
	my $sth=$dbh->prepare($sql);
	foreach my $i(@geneids){
		$sth->execute($i);
		while( my($accession) = $sth->fetchrow_array()){
			next if $accession eq '';
			push @records, $accession if join(' ',@records) !~ /$accession/ig;
		}
	}
	return @records;
}
# get the mouse/AGIL probename and symbol for a given accession
sub query_agil{
	my @accessions = @_;
	return 0 if (@accessions == 0);
	my %musgenes=();
	my $sql="select a.probename,a.unigene_symbol from mouse_rhdb.agilent_array a where genbank_accession=?";
	my $sth=$dbh->prepare($sql);
	#optimization: create list of ORs from the array
	foreach my $i(@accessions){
		$sth->execute($i);
		while( my($probename,$genesym) = $sth->fetchrow_array()){
			if (defined $musgenes{$probename}){
				#there should only be one gene per probe		
			} else {
				$musgenes{$probename} = $genesym;
			}
			#print "OUTPUT=$probename\t$genesym\n";
		}
	}
	return %musgenes;
}
sub open_db_conn{
	my $db = "test";
	my $db_host = "localhost";
	my $db_user = "root";
	my $db_pass = "smith1";
	$dbh = DBI->connect("DBI:mysql:database=$db:host=$db_host",
	$db_user, $db_pass, {RaiseError=>1}) or die "dberror: ".DBI->errstr;
}
sub print_array{
	my $arrayref = shift;
	foreach my $i (@$arrayref){
		print "$i\n";	
	}
}
