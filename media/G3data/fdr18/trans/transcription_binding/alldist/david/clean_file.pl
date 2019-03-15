#!/usr/bin/perl -w
#
use strict;

sub remove_column{
	my ($col, $file) = @_;
	open(INPUT, $file) || die "cannot open $file";
	<INPUT>;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		for (my $i=0; $i < scalar @d; $i++){
			next if $i==$col;
			print $d[$i];
			print "\t" if $i != scalar @d;
			print "\n" if $i == (scalar @d -1 );
		}
	}
}

######### MAIN #####################
unless (@ARGV == 2){
	print "usage $0 <column to remove, starting at 0> <file name>\n";
	exit(1);
}

remove_column($ARGV[0], $ARGV[1]);
