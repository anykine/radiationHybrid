#!/usr/bin/perl -w
# 8/16/07 RW
# modified: to use illumina human data w/ 50mers
# call modsim program and parse
# by convention, the 50mer probe is seq1 and the genbank file is seq2
use strict;
use DBI;

our $dbh;
our $gbdir = "./gbfiles/";
our $probedir = "./probefiles/";

unless (@ARGV == 1){
	print <<EOH;
	usage: $0 <tab-sep fasta table file>
	
	This script calls binary "modsim", a modified sim, based on input file
	(hamster_fastainfo.csv) to do alignments of hamster probes against
	mouse genes. By convention, seq1 is the 60mer probe and seq2 the genbank file.
	
	e.g. $0 hamster_fastainfo.csv
EOH
exit;
}

#loop through file of genbank records & their genes
open INPUT, $ARGV[0] or die "cannot open file\n";
open_db_conn();
<INPUT>; #skip first line
while (<INPUT>){
	# note: quotes around text; genes may have * after it
	#arr[1] = accession
	#arr[4] = gene
	my @line_data = split(/\t/);
	next if $line_data[4] eq '';
	#print "attempt $line_data[1]\t$line_data[4]\n";
	$line_data[4] =~ s/"//g;
	my @genes = split(/,/,$line_data[4]);
	next if $genes[0] eq 'skip';
	#print @genes;
	foreach my $el(@genes){
		#print "element of array genes: $el\n";
		my(@files) = query_db2file2($el);
		foreach my $file(@files){
			#print "element of array files: $file\n";
			my @results = call_sim($file, $line_data[1]);
			if (scalar @results){
				#print "\n*************\n";
				#print "RECORD: $file and $line_data[1]\n";
				parse_sim_output(\@results, $file, $line_data[1]);
			} else {

			}
		}
	}
}
#close INPUT;

sub test{
	my(@files) = query_db2file("hprt");
	my @results = call_sim("hprt0.txt", "t1");
	#my @results = call_sim("probe.txt", "hamster genbank");
	#my @results = call_sim("testfile2.txt", "testfile1.txt");
	if (scalar @results ) {
		parse_sim_output(@results);
	}
	#print $results[18];
}

### SUBROUTINES ###
sub open_db_conn{
	my $db = "human_rh";
	my $db_host = "localhost";
	my $db_user = "root";
	my $db_pass = "smith1";
	$dbh = DBI->connect("DBI:mysql:database=$db:host=$db_host",
	$db_user, $db_pass, {RaiseError=>1}) or die "dberror: ".DBI->errstr;
}

sub query_db2file2{
	# NEW: uses illumina data (human)
	#get the probe, write a fasta file
	my($gene) = @_;
	my @files = ();
	#remove * at end of genename; append wildcard 
	$gene =~ s/\*$//;
	$gene .= '%';
	#print "sql gene is $gene\n";
	my $sql = "select b.accession, b.symbol,a.ProbeID, b.Probe_Sequence 
			from ilmn_ref8syn1 a join ilmn_ref8 b on a.probeID=b.probeID where a.synonym like ?";
	my $count = 0;
	my $sth = $dbh->prepare($sql);
	$sth->execute($gene);

	while (my($acc, $genesym, $pname, $probe) = $sth->fetchrow_array()) {
		#print "$acc $unigene\n";
		my $file = lc($genesym) ."+$pname" . '.txt';
		my $filepath = './probefiles/'.$file;
		#print "file to be written: $file\n";
		#store the file FYI
		push @files, $file;
		#gene file may have already been written 
		next if (-e $filepath); 
		open OUTPUT, ">$filepath";
		print OUTPUT ">$acc|$genesym|$pname", "\n";
		print OUTPUT "$probe";
		close OUTPUT;
		$count++	
	}
	return @files;
}
sub query_db2file{
	#OLD: uses agilent data (mouse)
	#get the probe, write a fasta file
	my($gene) = @_;
	my @files = ();
	#remove * at end of genename; append wildcard 
	$gene =~ s/\*$//;
	$gene .= '%';
	#print "sql gene is $gene\n";
	my $sql = "select a.genbank_accession, a.unigene_symbol,a.probename, b.probe 
			from agilent_array a join agilent_probe b on a.probename = b.probename
			where unigene_symbol like ?";
	my $count = 0;
	my $sth = $dbh->prepare($sql);
	$sth->execute($gene);

	while (my($acc, $unigene, $pname, $probe) = $sth->fetchrow_array()) {
		#print "$acc $unigene\n";
		my $file = lc($unigene) ."+$pname" . '.txt';
		my $filepath = './probefiles/'.$file;
		#print "file to be written: $file\n";
		#store the file FYI
		push @files, $file;
		#gene file may have already been written 
		next if (-e $filepath); 
		open OUTPUT, ">$filepath";
		print OUTPUT ">$acc|$unigene|$pname", "\n";
		print OUTPUT "$probe";
		close OUTPUT;
		$count++	
	}
	return @files;
}

sub call_sim{
	#call sim program with <k> <seq1> <seq2> <mismatch> <gapopen> <gapextend>

	my($seq1,$seq2) = @_;	
	#modified sim program
	my $prog = './modsim'; 
	my $numberalignments = '1';
	my $files = 'seq_hamp.txt seq_humanp.txt';
	#my $files = 'testfile2.txt testfile1.txt';
	my $options2 = '-15 30 3';
	$seq1 = $probedir . $seq1;
	$seq2 = $gbdir . $seq2;
	unless (-e $seq1 || -e $seq2) {
		print "sequence file not found\n";
		return;
	}
	#store output as array of lines
	my @results = `$prog $numberalignments $seq1 $seq2 $options2`;
	return @results;
}

sub parse_sim_output{
	#my @simreport = @_;
	my($simreport,$file,$gb_recno) = @_;
	#get the similiary score
	my ($linesimilarity) = grep(/Similarity Score :/, @$simreport);
	my ($similarity) = ($linesimilarity=~ /\sSimilarity Score : (\d+)/);
	#get the match pct
	my ($linematchpct) = grep(/Match Percentage :/, @$simreport);
	my ($matchpct) = ($linematchpct =~ /\sMatch Percentage : (\d+)/);
	#get num matches
	my ($linenummatches) = grep(/Number of Matches :/, @$simreport);
	my ($nummatches) = ($linenummatches =~ /\sNumber of Matches : (\d+)/);
	#get num mismatches
	my ($linenummismatches) = grep(/Number of Mismatches :/, @$simreport);
	my ($nummismatches) = ($linenummismatches =~ /\sNumber of Mismatches : (\d+)/);
	#get gap length
	my ($linegaplen) = grep(/Total Length of Gaps :/, @$simreport);
	my ($gaplen) = ($linegaplen =~ /\sTotal Length of Gaps : (\d+)/);
	#get positions of match/mismatch
	my ($linepos) = grep(/Begins at/, @$simreport);
	my ($seq1start, $seq2start, $seq1end, $seq2end) = 
		($linepos =~ /Begins at \((\d+), (\d+)\) and Ends at \((\d+), (\d+)\)/);

	my @seq1 = grep(/^seq1/, @$simreport);
	my @align = grep(/\|\|/, @$simreport);
	my @seq2 = grep(/^seq2/, @$simreport);
	for (@seq1) { $_ = substr($_, 10, 60); s/\n//;}
	for (@align) {$_ = substr($_, 10, 60); s/\n//;}
	for (@seq2) { $_ = substr($_, 10, 60); s/\n//;}

	if ($nummatches > 33) {
		print "*******************************\n";
		print "RECORD: $file and $gb_recno\n";
		print "*******************************\n";
		print "sim=$similarity\tmatchpct=$matchpct\tnum_matches=$nummatches\tnum_mismatches=$nummismatches\tgaplen=$gaplen\n";
		print "seq1=$seq1start:$seq1end\tseq2=$seq2start:$seq2end\n";
		print join("", @seq1);
		print "\n";
		print @align;
		print "\n";
		print @seq2;
		print "\n";
		print "###\n";
	} else {
#		print "*******************************\n";
#		print "bad match\n";
#		print "###\n";
	}
}
