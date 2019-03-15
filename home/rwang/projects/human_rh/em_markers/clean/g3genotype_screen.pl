#!/usr/bin/perl -w

# scan retention freq file for low RF's and output which
# ones to remove
# command line options
#   -c remove bad markers
#   -f remove freq less than 5%
#   -t test 
use strict;
use Getopt::Std;
my %options = ();
getopts("rft", \%options);

if (defined $options{t}) { print "test worked\n";}

if (defined $options{r}) {
	# open genotype file and get rid of cell hybrids we don't have
	open(INPUT,"g3genotypes.txt") or die "cannot open file\n";
	
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
		# 48, 71, 76, 78 = 47, 70, 75, 77
		push (@newdata, @data[0..46]);
		push (@newdata, @data[48..69]);
		push (@newdata, @data[71..74]);
		push (@newdata, @data[76..76]);
		push (@newdata, @data[78..82]);

		my $newdata = join("",@newdata);
	#	my $data = join("",@data);
	#	print "$data\n";
		print "$newdata\n";
	}
}


# UNUSED
#pick out markers with low or high retention frequency
if (defined $options{r}) {
	open(INPUT,"g3clean.txt.rf.out") or die "cannot open file\n"; 
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		if ($data[0] < 0.05) || ($data[0] > 0.95)

	}
}

