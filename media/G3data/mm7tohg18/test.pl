#!/usr/bin/perl -w
use Bio::Perl;
use strict;

my $seq = get_sequence('swiss', "ROA1_HUMAN");
my $blast_result = blast_sequence($seq);
write_blast(">test.blast", $blast_result);
