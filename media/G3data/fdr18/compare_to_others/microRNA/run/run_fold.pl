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

# take a sequence, slide 110 nt window folding at each pos
# *both strands*

sub scan_window{
	#break this up, run on multiple cores/machines
	my $filesref = shift;
	#my @files = glob("mblock/*.fa");
	
	# loop over all files
	foreach my $file (@$filesref){
		my ($blocknum) = ($file =~ /(\d+)/);
		print STDERR $file,"\n";

		#create output file
		open(OUTPUT, ">mpin/mblock".$blocknum.".hpin.txt") || die "cannot open mblock$blocknum hairpin file";
		my $s = Bio::SeqIO->new(-file=>$file, -format=>'fasta');
		my $seq = $s->next_seq();
		my $start=1;
		#print $seq->length(),"\n"; 
	
		#do 110nt windows, first stand
		while($start < $seq->length()-110){
			#get a *string*
			my $seq_str = $seq->subseq($start, $start+109);
			my ($struct, $mfe) = RNA::fold($seq_str);
			#get reverse complement and fold
			my $revcom = reverse $seq_str;
			$revcom =~ tr/ACGTacgt/TGCAtgca/;
			my ($revstruct, $revmfe) = RNA::fold($revcom);

			# -25 is same thresh as Lim et al.
			if ($revmfe < $mfe && $revmfe < -25) {
				print OUTPUT join("\t", $blocknum, $start, $revmfe, '-'),"\n";
			} elsif ($mfe <= $revmfe && $mfe < -25){
				print OUTPUT join("\t", $blocknum, $start, $mfe, '+'),"\n";
			}
			$start+=1;
		} #end while

		# do the last fragment (ie pos[i] to pos[end] where length is <110)
		my $seq_str = $seq->subseq($start, $seq->length());
		my ($struct, $mfe) = RNA::fold($seq_str);
		my $revcom = reverse $seq_str;
		$revcom =~ tr/ACGTacgt/TGCAtgca/;
		my ($revstruct, $revmfe) = RNA::fold($revcom);
		if ($revmfe < $mfe && $revmfe < -25) {
			print OUTPUT join("\t", $blocknum, $start, $revmfe, '-'),"\n";
		} elsif ($mfe <= $revmfe && $mfe < -25){
			print OUTPUT join("\t", $blocknum, $start, $mfe, '+'),"\n";
		}
		
		close(OUTPUT);
	} #foreach file
}

# get one hairpin and look at it
sub test{
		my $file = "mblock/mblock369.fa";
		#my $file = "testfasta.fa";
		my $s = Bio::SeqIO->new(-file=>$file, -format=>'fasta');
		my $seq = $s->next_seq();
		print "len=",$seq->length(),"\n";
		my $frag = $seq->subseq(1940139,1940139+109);
		my ($struct, $mfe) = RNA::fold($frag);
		print "length = ", length($frag),"\n";
		#print $frag,"\n";
		#print $struct,"\n";
		#my $data = RNA::parse_structure($struct);
		#RNA::PS_rna_plot($frag, $struct, "rna.ps");	
		my $revcom = reverse $frag;
		$revcom =~ tr/ACGTacgt/TGCAtgca/;
		my ($revstruct, $revmfe) = RNA::fold($revcom);
		print "fwd is $mfe\n";
		if ($revmfe < $mfe && $revmfe < -25) {
			print "reverse strand\n";
			print $revstruct,"\n";
			print $revcom,"\n";
			print $revmfe,"\n";
			RNA::PS_rna_plot($revcom, $revstruct, "rna.ps");	
		} elsif ($mfe <= $revmfe && $mfe < -25){
			print "forward strand\n";
			print $struct,"\n";
			print $frag,"\n";
			print $mfe,"\n";
			RNA::PS_rna_plot($frag, $struct, "rna.ps");	
		}
}
sub testfold{
	my $seq = shift;
	my ($struct, $mfe) = RNA::fold($seq);
	print $seq,"\n";
	print "mfe=$mfe\n";
	print $struct,"\n";
	#RNA::PS_rna_plot($frag, $struct, "rna.ps");	
}

############# MAIN ###############
my $usage = "$0 startblock stopblock\n";
unless(@ARGV==2){ print $usage ; exit(1);} 

my @files = ();
#for (51..100){
for ($ARGV[0]..$ARGV[1]){
	push @files, "mblock/mblock".$_.".fa";
}
#print join("\n", @files),"\n";
scan_window(\@files);
#test();
