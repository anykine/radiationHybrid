#!/usr/bin/perl -w

# -removes bad clones from RHvectors (48,76,78,71)
# -flips output of make_marker_files.pl which are long but not wide (n x 83)
#  into files that very wide but not long (83 x n)
# -transforms "R" in rhvector to "2"


use strict;
use Data::Dumper;
use File::Path;

my $dirname="reformatted";
my $file;
my @rhdata = ();

#make a new subdir to place files
unless (mkpath($dirname)) {print "error\n"; exit;}

my @files_found = <rh_genotype_chr*.txt>;

foreach $file (@files_found){
	#$file = "test.in";
	#$file = "rh_genotype_chr1.txt";
	
	# open genotype file and get rid of cell hybrids we don't have
	open(INPUT,$file) or die "cannot open file: $file\n";
	open(OUTPUT, ">$dirname/$file") or die "cannot open output file! $file\n";
	while(<INPUT>){
		chomp;
		#replace ? and R
		s/\?/2/ig;
		s/R/2/ig;
	#	print "-----------\n";
		my @newdata=();
	#	print $_,"\n";
		my @data = split(//);
	#	print $#data,"\n";
		#need to exclude those clones that we don't have
		# 48, 71, 76, 78 which means get rid of 47, 70, 75, 77
		push (@newdata, @data[0..46]);
		push (@newdata, @data[48..69]);
		push (@newdata, @data[71..74]);
		push (@newdata, @data[76..76]);
		push (@newdata, @data[78..82]);
	
	#	my $newdata = join("",@newdata);
	#	my $data = join("",@data);
	#	print "$data\n";
	#	print "$newdata\n";
	
		push(@rhdata, [@newdata]);
	
	}	
	
	#file is a 2d matrix (@rhdata) in memory
	# now we reformat
	for(my $j=0; $j<=78; $j++){
		for (my $i=0; $i<=$#rhdata; $i++){
		# there are 79 clones in our dataset
			print OUTPUT $rhdata[$i][$j];
		}
			print OUTPUT "\n";
	}
	
	close(INPUT);
	close(OUTPUT);
	
#clear array
@rhdata=();
} #foreach

