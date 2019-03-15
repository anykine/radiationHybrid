#!/usr/bin/perl -w
use strict;
# create table of fasta header data

unless (@ARGV==1){
print <<EOH;
usage: $0 <file of fasta sequences>

 create table of fasta header data
 e.g. $0 690sequences.fasta
EOH
exit;
}
open INPUT, $ARGV[0] or die "cannot open file\n";

while(<INPUT>){
	if (/^>/) {
		chomp;
		my (@data) = split(/\|/);
		$data[0] =~ s/^>//;
		$data[4] =~ s/^\s//;
		my $data = join("\t", @data);
		print "$data\n";
	}
}
