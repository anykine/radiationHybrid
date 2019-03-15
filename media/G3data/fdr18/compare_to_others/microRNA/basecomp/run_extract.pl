#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;
#
# Extract microRNA sequences
#
#

# extract the mouse sequence within each mouse zero gene region
# to use for BLAST database
sub get_mus_miRNA_seq{
	open(INPUT, "../miRNA_mm7.txt") || die "cannot open mouse microRNA";
	my $id=1;
	my $curchrom = 1;
	my $seq = Bio::SeqIO->new(-file=>"/drive2/mm7/chr1.fa", -format=>'largefasta');
	my $seq_obj = $seq->next_seq();
	while(<INPUT>){
		chomp; next if /^#/;
		my @d= split(/\t/);
		$d[1] =~ s/chrX/chr20/;
		my ($chr) = ($d[1]=~ /chr(\d+)/);
		my ($start,$stop,$strand) = ($d[2], $d[3], $d[6]);
		#print join("\t", $chr, $start, $stop, $strand),"\n";
		
		if ($chr != $curchrom){
			my $file = "/drive2/mm7/chr".$chr.".fa";
			$seq = Bio::SeqIO->new(-file=>$file, -format=>'largefasta');	
			$seq_obj = $seq->next_seq();
			$curchrom = $chr;
		}
		my $frag = $seq_obj->subseq($start,$stop);
		if ($strand eq '-'){
			$frag = reverse $frag;
			$frag =~ tr/ACGTacgt/TGCAtgca/;
		}
		my $f= "mm7_miRNA".$id;
		print STDERR "doing miRNA", $id, "\n";
		my $out = Bio::SeqIO->new(-file => ">$f.fa", -format=>'fasta');
		my $newseq_obj = Bio::Seq->new(-display_id=>$f, -seq=>$frag);
		$out->write_seq($newseq_obj);
		$id++;
	}
}

# get the request sequence and write to file
#sub extract_seq{
#	my ($chr,$start,$stop,$id) = @_;
#	my $file = 	'/drive2/mm7/chr'.$chr.'.fa';
#	open(INPUT1, $file) || die "cannot open $file";
#	my @file = <INPUT1>;
#	close(INPUT1);
#	shift @file;
#	$chromdata = join("", @file); @file=();
#	$chromdata =~s/\n//g;
#	my $frag = substr $chromdata, $start, $stop-$start;
#	#print $frag;
#	open(OUTPUT, ">block".$id.".txt") || die "cannot open block for write";
#	print OUTPUT $frag;
#	close(OUTPUT);
#	$chromdata='';
#}



# Gotta use BioPerl
sub get_hum_zerogene_seq{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt") || die "No mouse 0gene";
	my $id=1;
	my $curchrom = 1;
	my $seq = Bio::SeqIO->new(-file=>"/drive2/hg18/hs_ref_chr1.fa", -format=>'largefasta');
	my $seq_obj = $seq->next_seq();
	while(<INPUT>){
		chomp; next if /^#/;
		my (undef,$chr,$start,undef,undef,$stop) = split(/\t/);
		
		# load new chrom if $chr changes
		if ($chr != $curchrom){
			print STDERR "loading new chrom $chr\n";
			my $file = "/drive2/hg18/hs_ref_chr".$chr.".fa";
			$seq = Bio::SeqIO->new(-file=>$file, -format=>'largefasta');	
			$seq_obj = $seq->next_seq();
			$curchrom = $chr;
		}
		#this is a string
		my $frag = $seq_obj->subseq($start,$stop+100);
		print STDERR "extracting ", $id,"$chr:$start-$stop\n";
		my $f= "hblock".$id;
		# this is a filestream
		my $out = Bio::SeqIO->new(-file=>">$f.fa", -format=>'fasta');
		# create new seq to be output by stream
		my $newseq_obj = Bio::Seq->new(-display_id=>$f, -seq=>$frag);
		$out->write_seq($newseq_obj);
		print STDERR "writing ", $id,"\n";
		$id++;
	}
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
get_mus_miRNA_seq();
#get_hum_zerogene_seq();
