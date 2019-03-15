#!/usr/bin/perl
#use lib '/usr/lib/perl5/vendor_perl/5.8.5';
use XML::DOM;

$file = $ARGV[0];

$xp = new XML::DOM::Parser();
$doc = $xp->parsefile($file);
$root = $doc->getDocumentElement();
print $root->toString();
