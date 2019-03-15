#!/usr/bin/perl -w

# 7/25/06
#
# this routine extracts protein interactions from the mint
# database. It gets the gene names involved in interactions
#
use strict;
use XML::Simple;
use Data::Dumper;

my($xml, $data, $intactionRef, $intactorRef);
$xml = new XML::Simple(ForceArray=>1, KeyAttr=>"content");

$data = $xml->XMLin("10023771_small.xml");
#print Dumper($data);
$intactionRef = $data->{entry}->{interactionList}->{interaction};
$intactorRef = $data->{entry}->{interactorList}->{interactor};

print Dumper($data);
