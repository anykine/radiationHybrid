#!/usr/bin/perl -w
use strict;
use Data::Dumper;

#read in marker1 pos1 marker2 pos2 pval
# this tells us if a genome coord is duplicated so we can
# remove that marker
unless (@ARGV ==1){
	print <<EOH;
	$0 <marker pos/pval file>

	This reads in a file of: 
		marker1 pos1 marker2 pos2 pval
	and tells us if a genome coord is duplicated so we can remove that marker
EOH
exit(0);
}
my %hash1=();
my %hash2=();
my $flag = 0;

open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	$hash1{$line[0]} = $line[1] if not exists $hash1{$line[0]};
	$hash2{$line[2]} = $line[3] if not exists $hash2{$line[2]};

}
#print Dumper(\%hash1);
#output hashes
print "------hash1------\n";
my @keys1 = sort keys %hash1;
for (my $i=0; $i<=$#keys1; $i++){
	print "$keys1[$i]\t$hash1{$keys1[$i]}";
	print "\tDuplicate!" if $hash1{$keys1[$i]} == $hash1{ $keys1[$i-1] } ;
	$flag = 1 if $hash1{$keys1[$i]} == $hash1{ $keys1[$i-1] } ;
	print "\n";
}
print "------hash2------\n";
my @keys2 = sort keys %hash2;
for (my $i=0; $i<=$#keys2; $i++){
	print "$keys2[$i]\t$hash2{$keys2[$i]}";
	print "\tDuplicate!" if $hash2{$keys2[$i]} == $hash2{ $keys2[$i-1] } ;
	$flag = 1 if $hash2{$keys2[$i]} == $hash2{ $keys2[$i-1] } ;
	print "\n";
}
print "Duplicates found!\n" if ($flag) ;
