#!/usr/bin/perl -w

use strict;
use Data::Dumper;

unless(@ARGV==0){
	print <<EOH;
	usage $0 <affy file to open> 
	
	Rip the RefSeq accession column from Affy annotation files. If
	multiple values exist (i.e., multiple RefSeq accessions)
	then create one line per value like so:
		probesetid	refseqacc
EOH
exit(0);
}
my %affyrefseq = ();   #probeid, refseqs
my %affygene = (); #probeid, gene symbols

# decision stuff
my $file ="HT_HG-U133A.na21.annot.strip.txt";
print "Reading in file HT_HG-U133A.na21.annot.strip.txt...\n";
print "\nExtract probesetID and (a) Refseq Accession \n(b) Gene Symbol\n(x) Exit\n";
my $which = <STDIN>;
chomp $which;
if ($which eq 'a') { $which='refseq';}
elsif ($which eq 'b') {$which ='genesymbol';}
else {exit(0);}

open(INPUT, $file) or die "cannot open file \n";

<INPUT>; #skip first line

while(<INPUT>){
	chomp;
	my @data = split(/\t/);
	#hash of affy probeset, array of refseqAccs
	if ($which eq 'refseq') {
		#skip their stupid empty cell --- 
		next if $data[12] eq '---';
		$affyrefseq{$data[0]} = { refseqs=> [ split(/\/\/\//, $data[12]) ]};
		foreach my $i (@{$affyrefseq{$data[0]}{refseqs}}) {
			$i=~s/^\s+//;
			$i=~s/\s+$//;
		}
		#hash of affy probeset, array of gene symbols
	} elsif ($which eq 'genesymbol'){
		next if $data[4] eq '---';
		$affygene{$data[0]} = {symbol => [split(/\/\/\//, $data[4])]};
		foreach my $i (@{$affygene{$data[0]}{symbol}}) {
			$i=~s/^\s+//;
			$i=~s/\s+$//;
		}
	#hash of affy probeset, array of gene symbols
	}
}
if ($which eq 'refseq') { output(\%affyrefseq);}
elsif ($which eq 'genesymbol') { output(\%affygene); }



sub output{
	my $counter = 0;
	my($hashref) = shift;
	open(OUTPUT, ">$file".".output.txt") or die "cannot open $file for write\n";
	foreach my $key (keys %{$hashref} ){
		foreach my $internalkey (keys %{$hashref->{$key}} ){
			foreach my $i (@{$hashref->{$key}{$internalkey}}){
				print OUTPUT "$key\t$i\n";
				$counter++;
			}
		}
	}
	close(OUTPUT);
	print "size of output = $counter\n";
}
#print Dumper(\%affyrefseq);
#output affy probesetid,symbol, refseq
#foreach my $key ( keys %affy){
#	foreach my $refseq (@{$affy{$key}{refseqs}}) {
#		print "$key\t$affy{$key}{symbol}\t";
#		print "$refseq\n";
#	}
#}
