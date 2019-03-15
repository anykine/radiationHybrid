#!/usr/bin/perl -w

use strict;
use Data::Dumper;

unless(@ARGV==2){
	print <<EOH;
	usage $0 <sql table organism1> <sql table organism2>
	 e.g. $0 logHumanG3.txt.input logRat.txt.input

	Compares the two files in the order given for overlap. The files
	for input have been modified with %%n [A|B]%% symbols to mark begin
	and end of sections. %%1 A%% means set1, part A which must have a 
	%%1 B%% somewhere else.

	The example compares HumanG3 against Rat. To compare rat against human
	you must reverse ARGV[0] and ARGV[1] in the example above.
	A positive hit would look somthing like:

	hit org1 at 1:A and org2 at 6:A for gene RICHARD=RICHARD
	hit org1 at 1:B and org2 at 6:B for gene WANG=WANG

	Since the 1A,1B pair in org1 hit against 6A,6B in org2
EOH
exit(0);
}

my $group;
my $item;
my %organism1=();
my %organism2=();

#open files and build hashes
open(INPUT, $ARGV[0]) or die "cannot open first file for read\n";
while(<INPUT>){
	chomp;
	if (/^%%/) { #look for my custom markup
		s/%%//ig;
		($group,$item) = split(/\s/);
		#print "$group is $item\n";	
	}
	next unless (/^\|/) || (/^%%/);  #skip all non-tables
	next if /^\|\sname/; #skip table header
	my @line = split/\s\|\s/; #we want the geneSymbol
	$line[4] =~ s/\s+$//ig;
	$line[4] =~ s/\s+\|//ig;
	my $geneSymbol = uc $line[4]; 
	#print $line[4],"\n";
	$organism1{$group}{$item}{$geneSymbol} = 1;
}
print Dumper(\%organism1);

#shitty, but do it again for 2nd organism
open(INPUT2, $ARGV[1]) or die "cannot open second file for read\n";
while(<INPUT2>){
	chomp;
	if (/^%%/) { #look for my custom markup
		s/%%//ig;
		($group,$item) = split(/\s/);
		#print "$group is $item\n";	
	}
	next unless (/^\|/) || (/^%%/);  #skip all non-tables
	next if /^\|\sname/; #skip table header
	my @line = split/\s\|\s/; #we want the geneSymbol
	$line[4] =~ s/\s+$//ig;
	$line[4] =~ s/\s+\|//ig;
	my $geneSymbol = uc $line[4]; 
	#print $line[4],"\n";
	$organism2{$group}{$item}{$geneSymbol} = 1;
}
print Dumper(\%organism2);

#do the comparison

#get the keys of %organism1
my @keys1 = sort keys %organism1;
my @keys2 = sort keys %organism2;
#print "@keys1";

my @AB = ('A','B');
# we always loop through organism1 and look for matches in orgnaism2
# that is, search organism 1 against organism 2
foreach my $i (@keys1){
	foreach my $j (@AB) {
		my @tmpgenes1 = keys %{$organism1{$i}{$j}};
			foreach my $org2_i (@keys2){
				foreach my $org2_j (@AB){
					my @tmpgenes2 = keys %{$organism2{$org2_i}{$org2_j}};
					foreach my $k (@tmpgenes1){
						#loop through organism2 tmp array
						foreach my $org2_k (@tmpgenes2){
							if ($k eq $org2_k){ print "hit org1 at $i:$j and org2 at $org2_i:$org2_j for gene $k=$org2_k\n";}
						}
					}
				}
			}
		#now loop through organism2
	}
}
