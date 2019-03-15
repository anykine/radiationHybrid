#!/usr/bin/perl -w
use SOAP::Lite;
$wsdl = 'http://soap.genome.jp/KEGG.wsdl';
$results = SOAP::Lite
						->service($wsdl)
						->list_pathways("eco");
foreach $path (@{$results}){
	print "$path->{entry_id}\t$path->{definition}\n";

}
