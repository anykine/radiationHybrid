#!/usr/bin/perl -w
#
use strict;
use Getopt::Std;
use Bio::SeqIO;

sub count_within_file{
	my $file = shift;
	return if (! -e $file);
	my $s= Bio::SeqIO->new(-file=> $file, -format=>'fasta');
	my $counter = 0;
	while( my $seq = $s->next_seq()){
		$counter++;
		#print $seq->display_id(),"\n";
	}
	return $counter;
}

sub count_all_files{
	my $dir = shift;
	my $totalcount = 0;
	#my @files = readdir DIR;
	my @files = glob("$dir/*.fa") ;
	#print @files,"\n";
	foreach my $f (@files){
		my $counter = count_within_file("$f");
		print "$f\t$counter\n";
		$totalcount += $counter;
	}
	print "total\t$totalcount\n";
}
############### MAIN  ###############
unless (@ARGV > 1){
	print <<EOH;
	Count the number of fasta entries within a file, or number within a directory
	usage $0 
		-f <fasta file>
		-d <directory of fasta files>

EOH
}

my %options=();
getopts('f:d:', \%options);

if (defined $options{f}){
	my $count = count_within_file($options{f});
	print "$options{f}\t$count\n";
} elsif (defined $options{d}){
	count_all_files($options{d});
}

