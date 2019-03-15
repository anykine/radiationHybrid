#!/usr/bin/perl -w
#
# determine the base composition for the sequences
use strict;
use Data::Dumper;
use Bio::SeqIO;

sub countA{
	my ($dna) = @_;
	my $count = ($dna =~ tr/Aa//);
	return $count;
}
sub countC{
	my ($dna) = @_;
	my $count = ($dna =~ tr/Cc//);
	return $count;
}
sub countG{
	my ($dna) = @_;
	my $count = ($dna =~ tr/Gg//);
	return $count;
}
sub countT{
	my ($dna) = @_;
	my $count = ($dna =~ tr/Tt//);
	return $count;
}

sub calc{
	my($numseqs, $hashref) = @_;
	my $tot = $$hashref{A} + $$hashref{C} + $$hashref{G}+$$hashref{T};
	print "num of seqs = $numseqs\n";
	print "num of basepairs = $tot\n";
	#print $$hashref{A},"\n";exit(1);
	#print $tot,"\n";exit(1);
	foreach my $k (keys %$hashref){
		print "freq of $k: ",$$hashref{$k}/$tot,"\n";
	}
}

sub run{
	my %stats = (A=>0, C=>0, G=>0, T=>0);
	# all known microRNAs
	my @files = glob("*.fa");
	# all zero gene regions
	#my @files = glob("../run/mblock/mblock*.fa");
	my $i=0;
	foreach my $f (@files){
		#print $f,"\n";
		my $s = Bio::SeqIO->new(-file=>$f, -format=>'fasta');
		my $seq = $s->next_seq();
		#print $seq->seq(),"\n";
		$stats{A} += countA($seq->seq());
		$stats{C} += countC($seq->seq());
		$stats{G} += countG($seq->seq());
		$stats{T} += countT($seq->seq());
		$i++;
	}

	calc($i, \%stats);
}

sub run_file{
	my $file = shift;
	my %stats = (A=>0, C=>0, G=>0, T=>0);
	my $i=0;
		print $file,"\n";
		my $s = Bio::SeqIO->new(-file=>$file, -format=>'fasta');
		my $seq = $s->next_seq();
		my $frag = $seq->subseq(12867,12967);
		#print $seq->seq(),"\n";
		$stats{A} += countA($frag);
		$stats{C} += countC($frag);
		$stats{G} += countG($frag);
		$stats{T} += countT($frag);
		$i++;

	calc($i, \%stats);
}
################### MAIN #################
run();
#run_file($ARGV[0]);
