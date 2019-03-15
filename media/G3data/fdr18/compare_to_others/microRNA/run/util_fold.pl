#!/usr/bin/perl -w
# 
#  *Do RNA folding on mouse zero gene regions, using a sliding
#   window of 110nt on both strands. Takes the better of
#   the two stands for the same loci (min MFE).
#  *Write output to 'mpin' directory. Bp pos are relative to block start.
#  *Mouse 0gene blocks indexed starting at 1 (not 0).
use strict;
use RNA;
use Bio::SeqIO;
use Data::Dumper;
use Getopt::Std;

# 
sub make_fold_plot{
		my ($file, $start, $strand ) = @_;
		
		#my $file = "testfasta.fa";
		my ($blocknum) = ($file =~ /\w+\/([m|h]block(\d+))/);
		$blocknum .= "-$start";
		my $s = Bio::SeqIO->new(-file=>$file, -format=>'fasta');
		my $seq = $s->next_seq();
		my $frag = $seq->subseq($start,$start+109);
		if ($strand eq '+'){
			my ($struct, $mfe) = RNA::fold($frag);
			RNA::PS_rna_plot($frag, $struct, "temp_".$blocknum."_f_rna.ps");	
		} elsif ($strand eq '-'){
			my $revcom = reverse $frag;
			$revcom =~ tr/ACGTacgt/TGCAtgca/;
			my ($revstruct, $revmfe) = RNA::fold($revcom);
			RNA::PS_rna_plot($revcom, $revstruct, "temp_".$blocknum."_r_rna.ps");	
		} else {
			print STDERR "not plus or minus strand\n";
		}
		#my $data = RNA::parse_structure($struct);
		#RNA::PS_rna_plot($frag, $struct, "rna.ps");	
}

# get one hairpin and look at it
sub make_fold_plot_mus{
		my ($blocknum, $start, $strand ) = @_;
		
		#my $file = "testfasta.fa";
		my $s = Bio::SeqIO->new(-file=>"mblock/mblock".$blocknum.".fa", 
		    -format=>'fasta');
		my $seq = $s->next_seq();
		my $frag = $seq->subseq($start,$start+109);
		if ($strand eq '+'){
			my ($struct, $mfe) = RNA::fold($frag);
			RNA::PS_rna_plot($frag, $struct, "mblock".$blocknum."_$start"."f_rna.ps");	
		} elsif ($strand eq '-'){
			my $revcom = reverse $frag;
			$revcom =~ tr/ACGTacgt/TGCAtgca/;
			my ($revstruct, $revmfe) = RNA::fold($revcom);
			RNA::PS_rna_plot($revcom, $revstruct, "mblock".$blocknum."_$start"."r_rna.ps");	
		} else {
			print STDERR "not plus or minus strand\n";
		}
		#my $data = RNA::parse_structure($struct);
		#RNA::PS_rna_plot($frag, $struct, "rna.ps");	
}
sub testfold{
	my $seq = shift;
	my ($struct, $mfe) = RNA::fold($seq);
	print $seq,"\n";
	print "mfe=$mfe\n";
	print $struct,"\n";
	#RNA::PS_rna_plot($frag, $struct, "rna.ps");	
}

sub usage{
	print <<EOH;
	usage: $0
	 -f <fasta file mblock/mblock1.fa>
	 -s <start pos>
	 -d <strand [+|-]>
EOH
exit(1);
}
############# MAIN ###############
print scalar @ARGV,"\n";
unless (@ARGV > 3){
	usage();
}
my %options=();
getopts("f:s:d:", \%options);
make_fold_plot($options{f}, $options{s}, $options{d});

