#!/usr/bin/perl -w
#
# smooth our CGH data (200000+ rows, 80+ cols) over a window of 10 adjacent probes
use strict;
use Data::Dumper;

unless (@ARGV==1){
	print <<EOH;
		$0 <file of cgh values>
			e.g. $0 g3matrix_pos_sorted_nodup.txt

		Smooth the data by averaging across a window of 10 adj probes. The kernel (of 10 here) 
		averages the 4 points before and 4 points after the current point meaning that it's
		centered on position 5.

		The output starts out with 4 lines of zeros because the the kernel cannot smooth before
		that. The last five lines of output are also zeros.

		Works for G3 CGH data. Expects the format:
			chr start stop rh1 .. rh80
EOH
exit(1);
}

my $WINDOWSIZE = 10;
my $NUMLINES = 235829;
my @matrix = ();
my @tmp = ();
my @zeros = ();

#output file
my $ofile = $ARGV[0] . "_smoothed";
open(OUTPUT, ">$ofile") || die "cannot open file for write\n";
#read the first 10 lines
open(INPUT, $ARGV[0]) || die "cannot open file for read\n";

#load first N rows into a matrix
for(my $i=0; $i<$WINDOWSIZE; $i++){
	my $line = <INPUT>;
	chomp $line;	
	push @matrix, [ split(/\t/, $line) ];
}

#easily output a row of 0's
for (my $j=0; $j<80; $j++){
	push @zeros, "0";	
}

#output first 4 rows of zeros
for (my $i=0; $i<4; $i++){
	print OUTPUT join("\t", @zeros), "\n";
	#print join("\t", @zeros), "\n";
}
#manually print out first average (line 5 in output)
my @result = average();
print OUTPUT join("\t", @result), "\n";

#do the rest
while(<INPUT>){
	#keep size of matrix constant by shifting and pushing. We're just movign the kernel down one
	#step at a time.
	shift(@matrix);
	chomp ;	
	push @matrix, [ split(/\t/) ];
	#print scalar @matrix, "\n";
	my @avg = average();
	print OUTPUT join("\t", @avg), "\n";
}

#output last 5 rows of zeros
for (my $i=0; $i<5; $i++){
	print OUTPUT join("\t", @zeros), "\n";
	#print join("\t", @zeros), "\n";
}

sub average{
	my @newdata =();
	#use global matrix
	# 10 rows, 3cols(chr,start,stop), 80 cols of numbers
	for (my $i=3; $i < 83; $i++){
		my $sum=0;
		for (my $j=0; $j<$WINDOWSIZE; $j++){
			$sum += $matrix[$j][$i];		
		}
		push @newdata, $sum/$WINDOWSIZE;
	}
	return @newdata;
}
