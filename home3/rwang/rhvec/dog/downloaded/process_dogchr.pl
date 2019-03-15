#!/usr/bin/perl -w
use strict;
use Data::Dumper;

#this script extracts highest (best match) from 
# BLAT alignments (dog_chrN.psl), flagging those that are not good matches
# relevant columns of output are:
# 0: match
# 9: query name (GENEnnnn)
# 10: query size
#
# one stupid lesson: do not mix how you treat a hash value: either its a reference or its a value
#  in the code below, doing $genes{$line[9])++ screwed everything up and was impossible to debug
my @files=(); #all my dog files
my %genes=();
for( my $i=1; $i<40; $i++){
	#print "dog_chr$i.psl ";
	push @files, "dog_chr$i.psl ";
}
foreach my $file(@files){
	open(INPUT, $file) or die "cannot open file $file for read\n";
		#read the file
		while(<INPUT>){
			my @line = split(/\t/);
			#create anon hash
			my %hashtmp= (match=>$line[0], 
											size=>$line[10],
											chrom=>$line[13],
											start=>$line[15],
											end=>$line[16]
										);
			#$line[9] is the name of the sequence/gene
			#print $line[9], "\n";
			if (exists $genes{$line[9]} ){
				#if current match % is higher, replace otherwise ignore
				if ( ($hashtmp{match})/($hashtmp{size}) > ($genes{$line[9]}->{match})/($genes{$line[9]}->{size}) ) {
					$genes{$line[9]} = { %hashtmp };
				}
			} else {
				$genes{$line[9]} = { %hashtmp };
#				$genes{$line[9]} = {
#											match=>$line[0], 
#											size=>$line[10],
#											chrom=>$line[13],
#											start=>$line[15],
#											end=>$line[16] 
#				};
			}
		}
	close(INPUT);
}
print Dumper(\%genes);

#iterate over gene hash
#get distribution of match percentages

#print GENE chrom start stop
for my $key ( keys %genes){
	print "$key\t$genes{$key}->{chrom}\t$genes{$key}->{start}\t$genes{$key}->{end}\n";
}

#summary info
print "size of unique keys in hash: ", scalar keys(%genes), "\n";
