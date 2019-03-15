#!/usr/bin/perl -w

use Bio::Tools::pSW;

$factory = new Bio::Tools::pSW(-matrix => 'blosum62.bla',
                                -gap => 12,
																-ext => 2, );
$factory->align_and_show($seq1, $seq2, STDOUT);
$aln = $factory->pairwise_alignment($seq1, $seq2);

