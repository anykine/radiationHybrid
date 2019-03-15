#!/usr/bin/perl -w
# 
# Takes KEGG pathway XML and extracts the nodes and edges
# and gets gene names
#
#
#
#


use strict;
use SOAP::Lite;
use Data::Dumper;
use XML::Twig;

############################3
# GLOBALS
#
############################3
my $file;
#my $file = $ARGV[0];
#my $file = "../xml/hsa04350.xml";
#my $file = "./test3.xml";
my %microarraygenes = ();
my %subtypes = ();    #relation subtypes
my $entryref = {};    #entries w/keggid & containers
my $DEBUG=1;

#SOAP stuff
my $wsdl= 'http://soap.genome.jp/KEGG.wsdl';
my $serv = SOAP::Lite->service($wsdl);

# uses DBGET interface to grab info
sub lookup{
	my($id) = shift;
	my $res = $serv->bget($id);
	return $res;
}
# parse DBGET file for name of genes, possibly multiple
# returns array of genes
sub parselookup{
	my($string) = shift;
	my @kegggenes=();
	#print "in lookup parse\n";
	#if ($string =~ /NAME/) {print "true\n"};
	while($string=~m/NAME\s+?(.+?)\n/g) {
		# here we need to check if gene name matches unigene
		my $value = $1;
		$value =~ s/\s//g;
		#crossreference with unigene names on uarray
		my @genelist = split(/,/, $value) if ($value=~/,/);
		foreach my $i(@genelist){
			my $key = uc $i;
			# if gene matches that in unigene, use it
			$value = $key if exists $microarraygenes{$key}; 
		}
		#if could not find a match in unigene hash, just pick one
		if ($value=~/,/) {
			my @genelist = split(/,/, $value);
			$value = $genelist[$#genelist];
		}
		push @kegggenes, $value;
		#print "match=", $value, "\n";
	}
	return @kegggenes;
}
#contains the reference gene names on microarray
sub load_microarray_reference{
	open(DB, "../../G4121A_unigenenames.txt") or die "cannot open microarray genes!\n";
	while(<INPUT>){
		#uppercase the key
		my $key = uc $_;
		if (defined $microarraygenes{$key}){
			$microarraygenes{$key}++;
		} else {
			$microarraygenes{$key}=1;
		}
	}
}

