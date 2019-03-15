#!/usr/bin/perl -w

#######################################
# read in fasta files and get gene names
#
#
#######################################
use strict;
use Bio::Perl;
use Bio::SeqIO;
#one big file of fastas
my $file = "690sequences.fasta";
my $inseq = Bio::SeqIO->new(-file => "<$file", -format =>"fasta");
my $gb = new Bio::DB::GenBank;

my @line_len=();
my $counter = 0;
our $gbseq ;
#loop thru all fastas
while (my $seq = $inseq->next_seq) {
	#extract identifier
	# first = gi
	# second = genbank id
	# third = database
	# fourth = accession
	my ($gi, $id, $gendb, $accession) = split /\|/, $seq->id ;
	#push @line_len, $1 if $seq->id =~ /gi\|(\d+)\|[a-zA-Z]\|([a-zA-Z0-9].)[|/;	
	#print $counter++, "\n";
	$counter++;
	if ($id ne '') {
		$gbseq = $gb->get_Seq_by_id($id);
	} else {
		$gbseq = "";
		next;
	}
	print "$id\t$accession\t";
#	my @features = grep {$_->primary_tag eq 'gene' } $gbseq->get_SeqFeatures;
#	for my $i (@features) {
#		my $gene = $i->get_tag_values("gene");
#		print "$gene\n";
#	}
	if ($gbseq ne "") {
		my @feat_objects = grep {$_->primary_tag eq 'gene'} $gbseq->get_SeqFeatures;
		for my $key (@feat_objects) {
			#push @ids, $key->get_tag_values("gene") if ($key->has_tag("gene"));     
			print $key->get_tag_values("gene")," ", if ($key->has_tag("gene"));     
		}
		print "\n";
	} else {
		print "\n";
	}
}
#my @genes = grep { $_->primary_tag eq 'gene'} $gbseq->all_SeqFeatures();
#		my $value = $genes[0]->get_tag_values("gene") if ($genes[0]->has_tag("gene"));
#		print $value,"\n";


##my @features = $seq1->all_SeqFeatures();
#my @genes = grep { $_->primary_tag eq 'gene'} $seq1->all_SeqFeatures();
#for my $feat_object (@genes) {
##for my $feat_object ($seq1->get_SeqFeatures) {
#	print "primary tag: ", $feat_object->primary_tag,"\n";
#	for my $tag ($feat_object->get_all_tags) {
#		print " tag: " , $tag, "\n";
#			for my $value ($feat_object->get_tag_values($tag)) {
#				print "    value: ", $value, "\n";
#			}
#	}
#}
##$seq2 = $gb->get_Seq_by_id('AF303112');
#$seqio = $gb0>get_Stream_by_id(["J00522", "AF303112", "2981014"]);
#$seq3 = $seqio->next_seq;

#$a = get_sequence('swiss', "ROA1_HUMAN");
#write_sequence(">roa1.fasta",'fasta',$a);
#print Dumper(\@features)
