#!/usr/bin/perl -w
use Bio::Seq;
use Bio::SeqIO;
use strict;

unless(@ARGV == 1){
	print <<EOH;
	usage: $0 <directory of dog chromosomes>

	Concatenates all gene sequences into one file; replaces fasta
	header identifier (nnnnnnnnnnn) with the file name:
	>GENE8884
	tgcatgcatgca

	Creates 1 file per chrom
EOH
exit(0);
}
#make a list of all sequences in dir
opendir(DIR, "$ARGV[0]");
my @files = grep(/-seq/, readdir(DIR));
closedir(DIR);

my $dir = $ARGV[0];
$dir =~ s/\///ig;

#create my output file
my $outio = Bio::SeqIO->new(-file=>">out$dir.fasta", -format=>'fasta');
#read them in one at a time
foreach my $fseq (@files){
	my $oseq1 = Bio::SeqIO->new(-file=>"$dir/$fseq", -format=>'fasta');
	my $seq1 = $oseq1->next_seq;
	#print $seq1->id, "\n";
	my $sequence = $seq1->seq;
	my ($geneid) = ($fseq=~ /(\w+)-seq/);
	#print "name=$geneid\n";	

	#create output seq obj
	my $tmpseq = Bio::Seq->new(-seq=>$seq1->seq,
															-id=>$geneid);
	$outio->write_seq($tmpseq);
}

