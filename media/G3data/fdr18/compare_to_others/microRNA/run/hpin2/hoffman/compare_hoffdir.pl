#!/usr/bin/perl -w
#
#
use strict;
use Data::Dumper;

open(INPUT, "hoffman2dir.txt") || die "cannot open hoffman2";
my %hoffman2 = map{ my @d = split(" "); $d[8] => $d[4]}
	grep {chomp; /hhit/; }
	<INPUT>;

#print Dumper(\%hoffman2);

open(INPUT, "hoffmandir.txt") || die "cannot open hoffman";
my %hoffman = map{ my @d = split(" "); $d[7] => $d[4]}
	grep {chomp; /hhit/; }
	<INPUT>;

my $errors = 0;
#print Dumper(\%hoffman);
foreach my $k (keys %hoffman2 ) { 
	if (defined $hoffman{$k}) {
		if ($hoffman{$k} == $hoffman2{$k}) {
			print "$k is safe\n";
		} else {
			$errors++;
		}
	} else {
		print "WARN: $k not in hoffman2 list\n";
	}
}
print "num keys hoffman = ", scalar keys %hoffman, "\n";
print "num keys hoffman2 = ", scalar keys %hoffman2, "\n";
print "err = $errors\n";
