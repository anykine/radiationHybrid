#!/usr/bin/perl -w
#
# use miRscan program
use strict;
use Bio::SeqIO;
use File::Temp qw/tempfile tempdir/;
use Data::Dumper;

# create the temp file with the format required by mirscan
sub do_mirscan{
	# hpin/1/hhit1.summary
	my ($infile) = @_;
	open(INPUT, $infile) || die "cannot open file $infile";
	while(<INPUT>){
		next if /^#/; chomp;

		# fetch the mouse hairpin
		#
		# fetch the human hairpin
		#
		# construct the temp file
		#
		# get the score
			
	}
}
#the input file for mirscan is 
# name (seq1) (seq2)
# Run this on one hhit###.summary file at a time
sub generate_mirscan_input{
	my $summaryfile= shift;
	open(INPUT, $summaryfile) || die "cannot open summary file $summaryfile";
	my $outputfile = $summaryfile.".mirscan";
	open(OUTPUT, ">$outputfile") || die "cannot open output file";
	while(<INPUT>){
		next if /^#/; chomp;
		my %data = ();
		my @data = split(/\t/);	
		#my $seq1 = fetch_mpin($data[0]);
		# get mouse hairpin
		my ($mblocknum, $offset, $strand) = ($data[0] =~/mblock(\d+):(\d+):([+-])/ );
		my $filename = build_filename('mouse',$mblocknum, $offset, $strand);
		my $s = Bio::SeqIO->new(-file=>$filename, -format=>'fasta');
		my $seq_obj = $s->next_seq();
		$data{mouse} = $seq_obj->seq();
			
		# get human hairpin
		my ($hblocknum) = ($data[3] =~ /hblock(\d+)/);
		$filename = build_filename('human',$hblocknum, $data[4], $data[6], $data[5]);
		$s = Bio::SeqIO->new(-file=>$filename, -format=>'fasta');
		$seq_obj = $s->next_seq();
		$data{human} = $seq_obj->seq();

		$data{name} = join(":", $data[0], $data[3], $data[4], $data[5], $data[6]);
		print Dumper(\%data);
		print OUTPUT "$data{name} $data{mouse} $data{human}\n";
	}
}

sub build_filename{
	my($species, $blocknum, $offset, $strand, $stop) = @_;
	my $strandletter = ($strand eq '+') ? 'p' : 'm';
	my $filename = "";
	if ($species eq 'mouse'){
		$filename = "mpin_split/$blocknum/mblock_" . $blocknum."_".$offset."_".$strandletter.".fa";
	} elsif ($species eq 'human'){
		$filename = "hpin/$blocknum/hblock_" . $blocknum."_".$offset."_".$stop."_".$strandletter.".fa";
	}
	print $filename,"\n";
	return $filename;
}
sub fetch_mpin{
	my $id = shift;
	my ($mblocknum, $offset, $strand) = ($id =~/mblock(\d+):(\d+):([+-])/ );
	print "$mblocknum -- $offset -- $strand \n";
	return;
}

############ MAIN ##################
my $usage = "usage $0 startblock stopblock\n";
unless(@ARGV==2) { print $usage; exit(1); }

my @files = ();
for ($ARGV[0]..$ARGV[1]){
	my $f = "hpin/$_/hhit".$_.".summary";
	push @files, $f if (-e $f);
}
#print Dumper(\@files);exit(1);
foreach my $f (@files){
	generate_mirscan_input($f);
}
