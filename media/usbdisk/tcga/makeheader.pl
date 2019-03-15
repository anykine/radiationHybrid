#!/usr/bin/perl -w
# for 240 CGH, need headers
my @header=();
open(INPUT, "matched_files.txt") || die "err $!";
while(<INPUT>){
	next if $. % 2 == 0;
	s/\d+\t\/media\/usbdisk\/tcga\/allcgh\///;
	my $s = substr $_, 0, 15;
	$s =~ s/-/\./g;
	push @header, $s;
}
print join("\t", @header);
