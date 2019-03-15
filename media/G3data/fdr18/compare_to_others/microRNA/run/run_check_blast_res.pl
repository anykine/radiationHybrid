#!/usr/bin/perl -w
#
# Take the blast hits (Mouse to Human 0-gene), 
# extract the hum seq, check against RNAfold for min reqs
# and process for mirscan
#
# process mouse to human 0-gene blast results
# create table of mouse zero gene hairpins and human seqs. 
# Extract human seqs in another step.
#
use strict;
use Bio::SearchIO;
use Data::Dumper;

sub process_blast{
	my $file = shift;
	#print $file,"\n";
	my $s = new Bio::SearchIO(-format=>'blast', -file=>$file);
	my $count = 0;
	my ($name) = ($file=~/blast\/(\w+)/);
	#print $name, "\n"; exit(1);
	open(my $fh, ">blastparse/" . $name. ".txt") || die "cannot open $name";
	# for each mouse hairpin in the file
	while (my $result = $s->next_result() ) {
		my %table=();	
		#print "num hits ", $result->num_hits,"\n";
	
		# the matching human ortho region
		while (my $hit = $result->next_hit() ) {
			# the position w/in human region
			while (my $hsp = $hit->next_hsp() ){
	
				next if $hsp->evalue > 1.8;
				# parse the query name for mouse block, position, strand info
				$table{queryname} = $result->query_name;
				#print "query name ", $result->query_name,"\n";
				$table{hitname} = $hit->name;
				#print "hit name ", $hit->name,"\n";
				#get query info
				$table{querystrand} = ($hsp->strand('query') == 1) ? '+' : '-';
				#print "strand ",$hsp->strand('query'),"\n";
				$table{querystart} = $hsp->start('query');
				#print "start ",$hsp->start('query'),"\n";
				$table{queryend} = $hsp->end('query');
				#print "stop ",$hsp->end('query'),"\n";
				#get hit info
				$table{hitstrand} = ($hsp->strand('hit')==1) ? '+' : '-';
				#print "strand ",$hsp->strand('hit'),"\n";
				$table{hitstart} = $hsp->start('hit');
				#print "start ",$hsp->start('hit'),"\n";
				$table{hitend} = $hsp->end('hit');
				#print "stop ",$hsp->end('hit'),"\n";
				
				##extract sequence from file and fold
				#my $hs = Bio::SeqIO->new(-format=>'fasta',-file=>'hblock/'.$hit->name.".fa");
				#my $seq = $hs->next_seq();
				#if ($hsp->strand('hit') == 1){
				#	my $seq_str1 = $seq->subseq($hsp->start('hit'), $hsp->end('hit')+100);
				#	my ($struct1, $mfe1) = RNA::fold($seq_str1);
				#	print $struct1,"\n", $mfe1,"\n";
				#	my $seq_str2 = $seq->subseq($hsp->start('hit')-100, $hsp->end('hit'));
				#	my ($struct2, $mfe2) = RNA::fold($seq_str2);
				#	print $struct2,"\n", $mfe2,"\n";
				#	
				#}
				#run through RNAfold
				#find max region
				#
				output_table(\%table, $fh); 
				$count++;
				#exit(1) if $count==10;
			}
		}
	}
	close($fh);
}
sub output_table{
		my ($table, $fh) = @_;
		#mblock101:<offset>:<strand> | query start | query end | query strand
		# hit start | hit end | hit strand
		# NOTE: <offset> + query start-1 is the offset from the start of zero gene block
		print $fh join("\t", $table->{queryname},
		$table->{querystart},
		$table->{queryend},
		$table->{querystrand}, 
		$table->{hitname},
		$table->{hitstart}, 
		$table->{hitend}, 
		$table->{hitstrand}
		),"\n";
}

############# MAIN #################
my $usage = "usage $0 startblock stopblock\n";
unless(@ARGV==2) { print $usage; exit(1); }

my @files = ();
for ($ARGV[0]..$ARGV[1]){
	my $f = "blast/mblock".$_.".bls";
	push @files, $f if (-e $f);
}
#print Dumper(\@files);exit(1);
foreach my $f (@files){
	process_blast($f);
}
