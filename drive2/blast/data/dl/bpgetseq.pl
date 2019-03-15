#!/usr/bin/perl -w
#
use Bio::Perl;
use Bio::DB::GenBank;

# messy - download genbank sequences as listed in ILMN table
#
	#my $db_obj = Bio::DB::GenBank->new;
my $db_obj = Bio::DB::RefSeq->new;
open(INPUT, "table.sql") || die "cannot open file\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	my $char = '.';
	my $frag = substr $line[2], 0, index($line[2], $char);
	#print $frag,"\n";
	#err handling
	eval {
		my $seq_obj = $db_obj->get_Seq_by_acc($frag) ;

		my $fname = 'seq'.$line[0].'.fa';
		write_sequence(">$fname", 'fasta', $seq_obj);
	};
	# if err, skip to next
	if ($@) {
		next;
	}
	#my $seq_obj = $db_obj->get_Seq_by_id($frag) ;
		#$seq_str = $seq_obj->seq;
		#print $seq_str;

}
