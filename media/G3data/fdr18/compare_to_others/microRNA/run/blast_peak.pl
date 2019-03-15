#!/usr/bin/perl -w
#
#use Bio::SeqIO;
use strict;
use lib '/home/rwang/lib';
use hummarkerpos;
use Data::Dumper;
use Math::Round;
use Bio::SearchIO;
use Bio::Seq;
use Bio::Tools::Run::StandAloneBlast;

#my $input_file = $ARGV[0];
#my $seq = Bio::SeqIO->new(-format => 'fasta', -file =>$input_file);


# my ghetto version of sequence extract
#
my $chromdat;
sub load_and_extract{
	my ($chromnum, $start, $stop) = @_;
	my $file = 'hs_ref_chr'.$chromnum.'.fa';
	open(INPUT, $file) || die "err\n";
	my @file = <INPUT>;
	close(INPUT);
	shift @file;
	$chromdat = join("", @file);
	@file=();
	$chromdat =~ s/\n//g;
	#print length($chrom),"\n";
	# substring start, length
	#my $frag = substr $chrom, $start, $stop-$start;
	#return $frag;
	print STDERR "done loading\n";
}

sub extract{
	my ($start, $stop) = @_;
	my $frag = substr $chromdat, $start, $stop-$start;
	return $frag;
}
#run blast against sequence, check if it hits correctly
sub do_blast{
	my ($seq, $geneidx, $markeridx) = @_;
	my @params = (program => 'blastn', database => 'g3seq.fa', -W =>7);
	my $blast_obj = Bio::Tools::Run::StandAloneBlast->new(@params);
	my $seq_obj = Bio::Seq->new(-id =>$geneidx, -seq=>$seq);
	
		my $report_obj = $blast_obj->blastall($seq_obj);
	LINE:
	 while(my $result = $report_obj->next_result ){
	 	while(my $hit = $result->next_hit ){
			while (my $hsp = $hit->next_hsp) {
					if ($hit->name eq $geneidx) {
						print "positive hit $geneidx $markeridx ";
						print "Hit\t", $hit->name, "\t", "Length\t", $hsp->length('total'),
							"\t", "Percent_id\t", $hsp->percent_identity, "\n";
						last LINE;
					} else {
						print "no hit for $geneidx $markeridx\n";
					}
			}
		}
	}
}
#$result_obj = $report_obj->next_result;

# does the area under zero gene eQTL peak blast match geneid?
sub feed_to_blast{
	my ($seq, $geneidx, $markeridx) = @_;
	#split into pieces
	my @data = split('', $seq);
	my $d = round(length($seq)/3);
	my @d = ();
	for (my $j=0; $j<4; $j++){
		$d[$j]=$j*$d; 
	}
	
	for (my $i=1; $i < 4; $i++){	
		print "running $i\n";
		my $str = join('', @data[$d[$i-1]..$d[$i]]);
		#print "$str, $i \n";
		do_blast( $str, $geneidx, $markeridx);
		#do_blast( $seq, $geneidx, $markeridx);
		#do_blast( $seq, 6985, $markeridx);
	}
	return 1;
}

######## RUN ##############
#import hummarkerpos_by_index{idx}{start/stop/pos/chrom}
load_markerpos_by_index("g3data");
#load_and_extract(20, 0, 0);
load_and_extract($ARGV[0], 0, 0);
open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/new/zero_gene_peaks_ucschg18.txt") || die "err\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	#limit to chrom 1
	#load_and_extract($chr, $start-100, $stop+100);
	#if ($line[1] >= 210826&& $line[1]<= 216158){
	if ($line[1] >= $ARGV[1] && $line[1]<= $ARGV[2]){
		#print $_,"\n";
		my $chr = $hummarkerpos_by_index{$line[1]}{chrom};
		my $start = $hummarkerpos_by_index{$line[1]}{start};
		my $stop = $hummarkerpos_by_index{$line[1]}{stop};
		#print "$chr $start $stop\n";
		#my $res = load_and_extract($chr, $start-100, $stop+100);
		my $res = extract( $start-100, $stop+100);
		#print $res,"\n";
		# args: sequence, geneidx, markeridx
		my $r = feed_to_blast($res, $line[0], $line[1]);
	}

}


sub usage{
	print <<EOH;
	$0 <chromosome to search> <start of markers on chrom> <end of markers on chrom>
	eg 16 184625 191418
EOH
exit(1);

}
