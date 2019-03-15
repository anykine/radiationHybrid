#!/usr/bin/perl -w

use lib '/home/rwang/lib';
use melttemp;

$seq = "qwerGTGGTGAGGAAGCTCCAGTC";
$ans = GCcontent(cleanseq($seq));

print "ans = $ans\n";
