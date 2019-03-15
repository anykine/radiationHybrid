#!/usr/bin/perl -w
#
# Some useful routines to examine FASTA files
use strict;
use Getopt::Std;
use Bio::SeqIO;

#print scalar @ARGV, "\n";
unless (@ARGV > 1){
	usage();
}
my %options=();
getopts('lrf:s:e:n:', \%options);

#print "-f $options{f}\n" if defined $options{f};
#print "-s $options{s}\n" if defined $options{s};
#print "-e $options{e}\n" if defined $options{e};
#print "-r $options{r}\n" if defined $options{r};
#print "Unprocessed by Getopt::Std:\n" if $ARGV[0];

sub usage{
	print <<EOH;
	usage: $0 
	 -f <FASTA filename>
	 -r get reverse comlement
	 -s <start>
	 -e <end>
	 -l get length
	 -n <directory of fasta files> num of frags in directory

	Note: blast report for mblock is relative to mblock PIN start site so you have 
	      to add the location of mpin start to the blast query start (-1)
EOH
exit(1);
}

sub get_frag{

	my $s = Bio::SeqIO->new('-file'=>$options{f}, '-format'=>'fasta');
	my $seq_obj = $s->next_seq();
	my $str = $seq_obj->subseq($options{s}, $options{e});

	# get the sequence
	if (defined $options{r}){
		print "rev seq: ";
		print revcom($str), "\n";
	} else {
		print "fwd seq: ";
		print $str,"\n";
	}
} 

sub get_length{
	my $s = Bio::SeqIO->new('-file'=>$options{f}, '-format'=>'fasta');
	my $seq_obj = $s->next_seq();

	#get the length only
	if (defined $options{l}){
		print "length: " . $seq_obj->length(),"\n";
		exit(1);
	}
}

sub revcom{
	my $s = shift;
	my $s1 = reverse $s;
	$s1 =~ tr/ACGTacgt/TGCAtgca/;
	return $s1;
}

# assume all files in directory end in .fa
sub get_num_fastas_dir {
	my $dir = shift;
	#within a fasta file
	# global counter
	my $gcounter = 0;
	my @files = glob("$dir/*.fa");
	print "number of files is :" ,scalar @files,"\n";
	foreach my $f (@files ) {
		my $counter = 0;
		my $s = Bio::SeqIO->new(-format => 'fasta', -file=>$f);
		while (my $seq_obj = $s->next_seq()){
			++$counter;
			++$gcounter;	
		}
		print "number of fasta sequences in $f: ", $counter, "\n";
	}
	print "number of fasta sequences in directory is ", $gcounter, "\n";
}
#################### MAIN ##############################
if (defined $options{l} ){
	get_length();
} elsif (defined $options{n}) {
	get_num_fastas_dir($options{n});
} else {
	get_frag();
}
