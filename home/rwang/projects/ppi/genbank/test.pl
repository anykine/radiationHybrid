#!/usr/bin/perl -w
use Data::Dumper;

@a1 = ('gene1', 'gene2', 'gene3');
@a2 = ('geneA', 'geneB', 'geneC');

push(@a1, @a2);
print "@a1";

%hash1 = ();
push @{$hash1{'one'}}, "word";
push @{$hash1{'one'}}, "two";
print %hash1, "\n";

print Dumper(\%hash1);

