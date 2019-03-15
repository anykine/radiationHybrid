#!/usr/bin/perl -w
# call testsim program and parse
# by convention, the 60mer probe is seq1 and the genbank file is seq2

use strict;
use DBI;
our $dbh;
#loop through file of genbank records & their genes
open INPUT, "hamster_fastainfo2.csv" or die "cannot open file\n";
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
		my(@files) = query_db2file($el);
		foreach my $file(@files){
			print "element of array files: $file\n";
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
	my $db = "mouse_rhdb";
	my $db_host = "localhost";
	my $db_user = "root";
	my $db_pass = "smith1";
	$dbh = DBI->connect("DBI:mysql:database=$db:host=$db_host",
	$db_user, $db_pass, {RaiseError=>1}) or die "dberror: ".DBI->errstr;

}
sub query_db2file{
	#get the probe, write a fasta file
	my($gene) = @_;
	my @files = ();
	$gene =~ s/\*$//;
	$gene .= '%';
	#print "sql gene is $gene\n";
	my $sql = "select a.probename,a.genbank_accession, a.unigene_symbol,a.probename, b.probe 
			from agilent_array a join agilent_probe b on a.probename = b.probename
			where unigene_symbol like ?";
	my $count = 0;
	my $sth = $dbh->prepare($sql);
	$sth->execute($gene);

	while (my($probename,$acc, $unigene, $pname, $probe) = $sth->fetchrow_array()) {
		#print "$acc $unigene\n";
		my $file = './probefiles/' . lc($unigene) . "+$probename". '.txt';
		#gene file may have already been written 
		#print "file to be written: $file\n";
		push @files, $file;

		next if (-e $file); 
		open OUTPUT, ">$file";
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
	my $prog = '../modsim'; 
	my $numberalignments = '1';
	#my $files = 'seq_hamp.txt seq_humanp.txt';
	#my $files = 'testfile2.txt testfile1.txt';
	my $options2 = '-15 30 3';

	my $seq1file = $seq1;
	my $seq2file = './gbfiles/' . $seq2;
	print "$seq1file\n";
	print "$seq2file\n";
	unless (-e $seq1file || -e $seq2file) {
		print "sequence file not found\n";
		return;
	}
	#store output as array of lines
	my @results = `$prog $numberalignments $seq1file $seq2file $options2`;
	return @results;
}

sub parse_sim_output{
	#my @simreport = @_;
	my($simreport,$file,$gb_recno) = @_;
	#get the match pct
	my ($linematchpct) = grep(/Match Percentage :/, @$simreport);
	my ($matchpct) = ($linematchpct =~ /\sMatch Percentage : (\d+)/);
	#get num matches
	my ($linenummatches) = grep(/Number of Matches :/, @$simreport);
	my ($nummatches) = ($linenummatches =~ /\sNumber of Matches : (\d+)/);
	#get num mismatches
	my ($linenummismatches) = grep(/Number of Mismatches :/, @$simreport);
	my ($nummismatches) = ($linenummismatches =~ /\sNumber of Mismatches : (\d+)/);

	my @seq1 = grep(/^seq1/, @$simreport);
	my @align = grep(/\|\|/, @$simreport);
	my @seq2 = grep(/^seq2/, @$simreport);
	for (@seq1) { $_ = substr($_, 10, 60); s/\n//;}
	for (@align) {$_ = substr($_, 10, 60); s/\n//;}
	for (@seq2) { $_ = substr($_, 10, 60); s/\n//;}

	if ($nummatches > 40) {
		print "*******************************\n";
		print "RECORD: $file and $gb_recno\n";
		print "*******************************\n";
		print "matchpct=$matchpct\tnum_matches=$nummatches\tnum_mismatches=$nummismatches\n";
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
