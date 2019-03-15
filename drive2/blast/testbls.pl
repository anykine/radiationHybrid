#!/usr/bin/perl -w
#
use Bio::SearchIO;
use Bio::Seq;
use Bio::Tools::Run::StandAloneBlast;

@params = (program => 'blastn', database => 'g3seq.fa');
$blast_obj = Bio::Tools::Run::StandAloneBlast->new(@params);
$seq_obj = Bio::Seq->new(-id =>"testquery", -seq=>"GGGAAGGGTGTTTGGAGGGCAGCGGCCGCCCCAAGCCGGAGCCCCGCAGCGCTTCTTATG");
$report_obj = $blast_obj->blastall($seq_obj);
 while($result = $report_obj->next_result ){
 	while($hit = $result->next_hit ){
		while ($hsp = $hit->next_hsp) {
				print "Hit\t", $hit->name, "\n", "Length\t", $hsp->length('total'),
					"\n", "Percent_id\t", $hsp->percent_identity, "\n";
		}
	}
}
#$result_obj = $report_obj->next_result;
print $result_obj->num_hits;

#while (my $hit = $report_obj->next_hit){
#	while (my $hsp = $hi->next_hsp){
#		print $hsp->score, " ", $hit->name, "\n"
#	}
#}
#
 #$report_obj = Bio::SearchIO->new(-format=>'blast', -file=>'test2.out');
 $report_obj = new Bio::SearchIO(-format=>'blast', -file=>'test2.out');
 while($result = $report_obj->next_result ){
 	while($hit = $result->next_hit ){
		while ($hsp = $hit->next_hsp) {
			if ($hsp->percent_identity > 75) {
				print "Hit\t", $hit->name, "\n", "Length\t", $hsp->length('total'),
					"\n", "Percent_id\t", $hsp->percent_identity, "\n";
			}
		}
	}
}
