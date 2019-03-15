#!/usr/bin/perl -w
# parse blat output to get good matches, name, chrom, start/end pos
# * removes chr from chr19
# * changes chrX to 23
# * changes chrY to 24
use strict; 

unless (@ARGV){
	print "usage: $0 <directory>\n";
	exit;
};

our($score, $name, $chrom, $pos_start, $pos_end);
chdir $ARGV[0] or die "cannot change to directory!\n";
opendir MYDIR, ".";
my @contents = grep !/^\.\.?$/, readdir MYDIR;

foreach my $file (@contents) {
	open(INPUT, $file) or die "cannot open file: $file!\n";
	while (<INPUT>) {
		chomp;
		my @data = split(/\t/);
		#column 1 is match score
		if ($data[0] > 45) {
			$score = $data[0];
			$name = $data[9];
			$chrom = $data[13];
			$chrom =~ s/chr//;
			$chrom = 23 if $chrom eq 'X';
			$chrom = 24 if $chrom eq 'Y';
			$pos_start = $data[15];
			$pos_end = $data[16];
			print "$score\t$name\t$chrom\t$pos_start\t$pos_end\n";
		}
	}
	close(INPUT);
}
closedir MYDIR;
