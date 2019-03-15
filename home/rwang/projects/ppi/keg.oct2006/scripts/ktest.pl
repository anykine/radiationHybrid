#!/usr/bin/perl
use SOAP::Lite;

$wsdl = 'http://soap.genome.jp/KEGG.wsdl';

$serv = SOAP::Lite->service($wsdl);

$offset = 1;
$limit = 5;

$top5 = $serv->get_best_neighbors_by_gene('eco:b0002', $offset, $limit);

foreach $hit (@{$top5}) {
  print "$hit->{genes_id1}\t$hit->{genes_id2}\t$hit->{sw_score}\n";
}
