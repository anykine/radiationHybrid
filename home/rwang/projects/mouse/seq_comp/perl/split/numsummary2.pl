#!/usr/bin/perl -w

#use strict;
unless (@ARGV == 1) {
	print <<EOH;
	usage: $0 <file to read>

	this program looks at output of exsim.pl and 
	reads in probe_rvalues.txt (from chris data)
	and summarizes the data

	this program is more strict than numsummary.pl
	in that it counts gaps as mismatches

	e.g. $0 ./hamster_compv4.txt
EOH
	exit 0;
}
our %db = ();
########
	open INPUT, "probe_rvalues.txt" or die "cannot open rvalues\n";
	while (<INPUT>){
		chomp;
		my @data = split(/\t/,$_);
		$db{$data[0]} =$data[1];
	}
	close INPUT;
########
open INPUT, $ARGV[0] or die "cannot open file\n";
$/ = "###";
my %recdata = ();
my($gene, $probename);
my $cou=0;
while (my $record = <INPUT>){
	#my($gene,$probename) = ($record =~ /^RECORD: ([a-z][0-9]+)\+(A_51_.+)\.txt/ms); 
	$record =~ /^RECORD:\s(.+)\.txt/m; 
	$gene = $1; 
	my @names = split(/\+/, $gene);
	#print $names[0], $names[1],"\n";
	my ($mismatch) = ($record =~ /num_mismatches=(\d+)/m);
	my ($match) = ($record =~ /num_matches=(\d+)/m);
	my ($seq1start,$seq1end) = ($record =~ /^seq1=(\d+):(\d+)/m);
	my ($graphic) = ($record =~ /^(\|.+)\n/m);
	#skip gapped sequences
 	#print "graphic:$graphic\n";
	next if ($graphic =~ /-/mg);
	#my $mm = countgraphic($graphic);
 	#print "$seq1start and $seq1end\n";
 	if ($seq1start != 1){
 		my $mm = $seq1start - 1;
 		#print "start adj, add $mm\n";
 		$mismatch += $mm;
 	}
 	if ($seq1end != 60){
 		my $mm2 = 60 - $seq1end;
 		#print "end adj, add $mm2\n";
 		$mismatch += $mm2;
 	}	
 	if ($mismatch + $match != 60) {
 		#print "ERROR\n";
 	}
#	print $mismatch, "\n"; 
#	print $match, "\n"; 
#	print "$record\n";
	my $rval = $db{$names[1]};
	print "$gene\t$mismatch\t$rval\n";
}
#while( my($k,$v) = each(%genelist) ) {
#	print "gene=$k count=$v\n";
#	$count++;
#}
#for my $k (sort keys %seqlist){

sub builddb {
	open INPUT, "probe_rvalues.txt" or die "cannot open rvalues\n";
	while (<INPUT>){
		my @data = split(/\t/,$_);
		$db{$data[0]} =$data[1];
	}
}
#not ready to be used
# need to figure out what to do with gaps (seq1 or seq2)
sub countgraphic{
	my $align = shift;
	my @seq = split(//,$align);
	my $match=0;
	my $mm=0;
	my $gap=0;
	for ($i=0; $i<length($align); $i++){
		$match++ if $seq[$i] eq '|';
		$mm++ if $seq[$i] eq 'x';
		$gap++ if $seq[$i] eq '-';
	}
	if (length($align) != 60) {
		$mm += 60-length($align);	
	}
	#$mm = $mm+$gap;
	print "match=$match mm=$mm gap=$gap\n";
	return $mm;
}
