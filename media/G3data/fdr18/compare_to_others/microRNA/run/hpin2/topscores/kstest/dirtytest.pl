#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;
sub log10 {
  my $n = shift;
	return log($n)/log(10);
}
																																	
my %list = ();
open(INPUT, "tmp1" ) || die "cannot open file1";
while(<INPUT>){
	chomp; next if /^#/;
	my @data = split(/\t/);
	my $nlp;
	if ($data[0] == 0){
	 $nlp = 0;
	}  else {
		$nlp = log10($data[0]) * -1;
	}
	if (defined $list{$data[1]}){
		$list{$data[1]} = $nlp if $nlp > $list{$data[1]};
	} else {
		$list{$data[1]} = $nlp;
	}
}
close(INPUT);
#print Dumper(\%list);
#
my %hash = ();
open(INPUT, "../no5.cghall.sort") || die "cannot open file2";
while(<INPUT>){
	next if /^#/; chomp;
	my @data = split(/\t/);
	if (defined $list{ $data[0] } ){
		print join("\t", @data), "\t**************\n";
	} else {
		print join("\t", @data), "\n";
	}
}
