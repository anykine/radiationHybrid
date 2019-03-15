#!/usr/bin/perl -w
# AGIL files (agil_pos.txt) have this structure
#agil_unigene_symbol, kgID, name, chrom, txStart, txEnd
# ILMN files (ilmn_pos.txt.bed.translated) have this structure
#chrom$, start, stop, symbol

use strict;
use Data::Dumper;

unless(@ARGV == 2){
	print <<EOH;
	usage $0 <file to parse and sort> <ILMN or AGIL>
		e.g. $0 ilmn_pos.txt.bed.translated ILMN

	Takes input file of genes and creates one file per chromosome
	and sorts those files. Files are places in comp_agil/ or comp_ilmnT/

EOH
exit(0);
}
unless ($ARGV[1] eq 'ILMN' || $ARGV[1] eq 'AGIL'){
	print "Error: You must specify ILMN or AGIL\n";
	exit(0);
}

my %chromdata=();  #keys are chrom#'s, values are textline start,end,name
open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
while(<INPUT>){
	if ($ARGV[1] eq 'AGIL') {
		chomp;
		my @data = split(/\t/);
		next if $data[3] =~ /random/;
		my $newdata = "$data[3]\t$data[4]\t$data[5]\t$data[0]\t$data[1]\t$data[2]";
			if (exists $chromdata{$data[3]} ){
				push @{$chromdata{$data[3]}}, $newdata; 
			} else {
				$chromdata{$data[3]} = [ $newdata ];
			}
	} elsif ($ARGV[1] eq 'ILMN') {
		chomp;
		my @data = split(/\t/);
		next if $data[0] =~ /random/;
		#get rid of leading chr
		$data[0] =~ s/chr//;
			if (exists $chromdata{$data[0]})  {
				push @{$chromdata{$data[0]}},  join("\t",@data) ;
				#jprint "added=", join("\t",@data), "\n";
			} else {
				$chromdata{$data[0]} = [ join("\t",@data)];
				#print "joined=",join("\t",@data), "\n";
			}
	} else {
		print "error in command line\n";
	}
}
#print Dumper(\%chromdata);
foreach my $key (keys %chromdata){
	if ($ARGV[1] eq 'AGIL') {
		open(OUTPUT, ">./comp_agil/data$key.txt") or die "cannot open file for write\n";
	} else {
		open(OUTPUT, ">./comp_ilmnT/data$key.txt") or die "cannot open file for write\n";
	}
	#sorts based on position
	@{$chromdata{$key}} = sort { (split /\t/, $a)[1] <=> (split /\t/,$b)[1]} @{$chromdata{$key}};
	#finds unique entries in array (sorta)
	my %seen=();
	@{$chromdata{$key}} = grep { ! $seen{$_}++ } @{$chromdata{$key}};
	#output
	foreach my $i (@{$chromdata{$key}}){
		print OUTPUT"$i\n";
	}
	close(OUTPUT);
}
my @chroms = sort keys %chromdata;
print "@chroms\n";
#print Dumper(\%chromdata);
