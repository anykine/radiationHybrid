#!/usr/bin/perl -w
#
#use Bio::SeqIO;
use strict;
use Data::Dumper;
use Math::Round;
use Bio::SearchIO;
use Bio::Seq;
use Bio::Tools::Run::StandAloneBlast;

#my $input_file = $ARGV[0];
#my $seq = Bio::SeqIO->new(-format => 'fasta', -file =>$input_file);


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
		do_blast( $str, $geneidx, $markeridx);
	}
	return 1;
}

# foreach mpin file, write out blast report
sub blast_all_pins{
	my ($infile,$outfile) = @_;
	my @params = (program => 'blastn', database => 'g3zerogene.fa', -W =>7, -outfile=>$outfile);
	#my $infile = "mpinfasta/mblockpins9.fa";
	my $s = Bio::SeqIO->new('-file'=>$infile, '-format'=>'fasta');

	my $blast_obj = Bio::Tools::Run::StandAloneBlast->new(@params);
	# array of Seq objects
	my @seq_objs=();
	while (my $seq = $s->next_seq()){
		push @seq_objs, $seq;
	}
	#print scalar @seq_objs,"\n";exit(1);
	# result is searchIO object
	my $r= $blast_obj->blastall(\@seq_objs);
	# result object
	#my $res = $r->next_result();
	#print "number of hits is ",$res->num_hits(),"\n";
	#print "query name:",$res->query_name(),"\n";
	#print "db name:",$res->database_name(),"\n";
	#$res = $r->next_result();
	#
	#print "number of hits is ",$res->num_hits(),"\n";
	#print "query name:",$res->query_name(),"\n";
	#print "db name:",$res->database_name(),"\n";
		#while(my $hit = $res->next_hit() ){
		#	print "hit name:",$hit->name,"\n";
		#	print "hit length:", $hit->length(), "\n";
		#	print "hit desc:", $hit->description(), "\n";
		#	print "num hsps:", $hit->num_hsps(), "\n";
		#	# if there are multiple HSPs there will be no eval
		#	print "hit e-val:", $hit->significance(), "\n";
		#	while (my $hsp = $hit->next_hsp() ){
		#		print "hsp e-val:", $hsp->evalue,"\n";
		#	}
		#print "--------------\n";
		#}
}
sub testrun{
	my @params = (program => 'blastn', database => 'g3zerogene.fa', -W =>7);
	my $file = "mpinfasta/mblockpins9.fa";
	#my $file = "/drive2/blast/t.g3zero97";
	my $s = Bio::SeqIO->new('-file'=>$file, '-format'=>'fasta');
	my $blast_obj = Bio::Tools::Run::StandAloneBlast->new(@params);
	my $exe = $blast_obj->executable('blastall');
	#my $seq_obj = Bio::Seq->new(-id =>$geneidx, -seq=>$seq);
my $seq = $s->next_seq();	
	my $report_obj = $blast_obj->blastall($seq);
	 while(my $result = $report_obj->next_result() ){
	 	while(my $hit = $result->next_hit ){
			while (my $hsp = $hit->next_hsp) {
				print Dumper($hsp);
			}
		}
	}
}

sub testwrite{
	my @params = (program => 'blastn', database => 'g3zerogene.fa', -W =>7,-outfile=>'t.blast.out');
	my $file = "mpinfasta/mblockpins9.fa";
	#my $file = "/drive2/blast/t.g3zero97";
	my $s = Bio::SeqIO->new('-file'=>$file, '-format'=>'fasta');
	#my $seq = $s->next_seq();
	my @seq_obs=();
	push @seq_obs, $s->next_seq();
	my $seq = $s->next_seq();
	my $blast_obj = Bio::Tools::Run::StandAloneBlast->new(@params);
	my $exe = $blast_obj->executable('blastall');
	my $report_obj = $blast_obj->blastall($seq);

	#can i have multiple reports?

}
sub test1{
	my $in = new Bio::SearchIO(-format=>'blast', -file=>'t.blast.out');
	while( my $res = $in->next_result()){
		print "number of hits is ",$res->num_hits(),"\n";
		print "query name:",$res->query_name(),"\n";
		print "db name:",$res->database_name(),"\n";
		while(my $hit = $res->next_hit() ){
			print "hit name:",$hit->name,"\n";
			print "hit length:", $hit->length(), "\n";
			print "hit desc:", $hit->description(), "\n";
			print "num hsps:", $hit->num_hsps(), "\n";
			# if there are multiple HSPs there will be no eval
			print "hit e-val:", $hit->significance(), "\n";
			while (my $hsp = $hit->next_hsp() ){
				print "hsp e-val:", $hsp->evalue,"\n";
			}
		print "--------------\n";
		}
	}

}
###### MAIN ##########3
#testrun();
#testwrite();
#test1();
my @files = glob("mpinfasta/mblockpins*.fa");
#push my @files, "mpinfasta/mblockpins441.fa";
foreach my $f (@files ){
	my ($num) = ($f =~ /mblockpins(\d+)\.fa/);
	print $f,"\n";
	print $num,"\n";
	my $outfile = "blast/mblock".$num.".bls";	
	print $outfile,"\n";
	blast_all_pins($f,$outfile);
}
