#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;
use RNA;
use Data::Dumper;

# Using the sorted blastparse file, read in each matching human 0-gene region,
#  extract from human sequence, attempt folding, and if passed,
#  write out sequence to file
#

# Extract the human sequence within each human zero gene region.
# Takes advantage of the sorted input so each human frag loaded once and all subseqs extracted
sub get_hum_zerogene_seqfrag{
	my ($infile) = @_;
	open(INPUT, $infile) || die "No human sorted infile";
	my $id=1;
	$_=<INPUT>; chomp $_;
	my @data = split(/\t/, $_);
	#use blocknum one time only
	my ($blocknum) = ($data[4] =~ /hblock(\d+)/);
	my $curhblocknum = $blocknum;
	my $seq = Bio::SeqIO->new(-file=>"hblock/hblock".$blocknum.".fa", -format=>'fasta');
	my $seq_obj = $seq->next_seq();
	#rewind to beginning of file
	seek(INPUT, 0, 0);

	while(<INPUT>){
		chomp; next if /^#/;
		#change
		my (undef,undef,undef,undef,$hblock,$hstart,$hstop,$hstrand) = split(/\t/);
		my ($hblocknum) = ($hblock =~ /hblock(\d+)/);
		print join('\t', $hblock, $hstart, $hstop, $hstrand),"\n";	
		# load new chrom if $chr changes
		if ($hblocknum != $curhblocknum){
			print STDERR "loading new block $hblocknum\n";
			my $file = "hblock/hblock".$hblocknum.".fa";
			$seq = Bio::SeqIO->new(-file=>$file, -format=>'fasta');	
			$seq_obj = $seq->next_seq();
			$curhblocknum = $hblocknum;
		}
		my %fold=();
		#test for folding
		# positive strand
		if ($hstrand eq '+'){
			$fold{1} = $seq_obj->subseq($hstart,$hstop+100);
			$fold{2} = $seq_obj->subseq($hstart-100,$hstop);
			print STDERR "extracting ", $id,"$hblock:$hstart-$hstop\n";
			max_fold(\%fold);
			my $f= "hblock".$id;
		# negative strand
		} elsif ($hstrand eq '-') {
			$fold{1} = revcom($seq_obj->subseq($hstart,$hstop+100));
			$fold{2} = revcom($seq_obj->subseq($hstart-100,$hstop));
			max_fold(\%fold);
		}
		# run through RNAfold
		
		# this is a filestream
		#my $out = Bio::SeqIO->new(-file=>">$f.fa", -format=>'fasta');
		## create new seq to be output by stream
		#my $newseq_obj = Bio::Seq->new(-display_id=>$f, -seq=>$frag);
		#$out->write_seq($newseq_obj);
		#print STDERR "writing ", $id,"\n";
		$id++;
	exit(1);}
}

# do the RNA fold and pick the max of two choices
sub max_fold{
	my $hashref = shift;
	my @ans = ();
	foreach my $k (keys %$hashref){
		my ($struct, $mfe) = RNA::fold($hashref->{$k});
		print "key=$k ", $mfe,"\n";
	}
}

sub revcom{
	my $seq = shift;
	my $revcom = reverse $seq;
	$revcom =~ tr/ACGTacgt/TGCAtgca/;
	return $revcom;
}
# get the request sequence and write to file
#sub extract_hum_seq{
#	my ($chr,$start,$stop,$id) = @_;
#	my $file = 	'/drive2/hg18/hs_ref_chr'.$chr.'.fa';
#	open(INPUT1, $file) || die "cannot open $file";
#	my @file = <INPUT1>;
#	close(INPUT1);
#	shift @file;
#	$chromdata = join("", @file); @file=();
#	$chromdata =~s/\n//g;
#	my $frag = substr $chromdata, $start, $stop-$start;
#	#print $frag;
#	open(OUTPUT, ">hblock/hblock".$id.".txt") || die "cannot open block for write";
#	print OUTPUT $frag;
#	close(OUTPUT);
#	$chromdata='';
#}

sub test{
	my $a = Bio::SeqIO->new(-file=>'hblock1.fa', -format=>'fasta');
	my $seq_obj = $a->next_seq();
	print $seq_obj->length();
}
############## MAIN ####################3 
# prep for creating blast database

get_hum_zerogene_seqfrag("blastparse/mblock9.txt.sort");
