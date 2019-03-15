#!/usr/bin/perl -w
#RW 8/23/07
# modified: I want to compare position with Rvalue, so I extract the graphic and names of hamster/mouse seqs/probes
# yes this is a hack.
use strict;
use Data::Dumper;

unless (@ARGV == 1) {
	print <<EOH;
	usage: $0 <file to read>

	BEWARE this is modified! (see comments) this program looks at output of exsim.pl and 
	reads in probe_rvalues.txt (from chris data) and summarizes the data. Rvalue versus position.

	e.g. $0 ./hamster_compv5-ordered-pruned.txt
EOH
	exit 0;
}
our %db = (); #probename => rvalue 
########
builddb();
########
open INPUT, $ARGV[0] or die "cannot open file\n";
$/ = "###";
#array of graphics, all length 60
my @arrgraphics = ();
#these arrays are synchronized: 1st graphic is 1st probename
my @probenames= ();
#header line
#print "gene\tsimilarityscore\tmatchpct\tnummatches\tnummismatches\tgaplen\trval\n";
while (my $record = <INPUT>){
	my($gene,$probename,$genbankfile)=($record =~ /^RECORD:\s(.+)\+(\w+)\.txt and (\d+)/m); 
	my ($sim,$matchpct,$match,$mismatch,$gaplen) = 
		($record =~ /^sim=(\d+)\tmatchpct=(\d+)\tnum_matches=(\d+)\tnum_mismatches=(\d+)\tgaplen=(\d+)$/m);
	my ($seq1start,$seq1end,$seq2start,$seq2end) = ($record =~ /^seq1=(\d+):(\d+)\tseq2=(\d+):(\d+)/m);
	my ($seq1,$graphic,$seq2) = ($record =~ /^([ACTG ]+)\n^([\|x-]+)\n^([ACTG ]+)/m);

	#skip if gaps in alignment
	next if ($graphic =~ /-+/);

	my $newgraphic = undef;	
	if ($seq1start != 1 || $seq1end != 60){
		my($extramatch,$extramismatch)= (0,0);
		($extramatch,$extramismatch,$newgraphic)=recompute("$gene+$probename.txt",$genbankfile,$seq1start,$seq1end,$seq2start,$seq2end,\$graphic);
		#print "match $match\tmmatch $mismatch\n";
		#print "extramatch $extramatch\textrammatch $extramismatch\n";
		$match += $extramatch;
		$mismatch += $extramismatch;
		#print "match $match\tmmatch $mismatch\n";
	}
#	print $mismatch, "\n"; 
#	print $match, "\n"; 
#	print "$record\n";
	my $rval = $db{$probename};
	#my $rval = $db{$names[1]};
#	print "$gene\t$sim\t$matchpct\t$match\t$mismatch\t$gaplen\t$rval\n";
	#print $graphic, "\n";
	#print $newgraphic,"\n" if defined $newgraphic;
	#print "---------\n";

	#filll arrgraphics and probenames in sync
	if (defined $newgraphic){
		push @arrgraphics, [ split(//, $newgraphic) ];
	} else {
		push @arrgraphics, [ split(//, $graphic) ];
	}
	push @probenames, $probename;
} #end while loop

#print "size of arragraphics is ", scalar @arrgraphics, "lastindex $#arrgraphics\n";
#print "size of probenames is ", scalar @probenames, "lastindex $#probenames\n";
#build_pos_report(\@arrgraphics);
#print Dumper(\@arrgraphics);
#printMatrix(\@arrgraphics, \@probenames);
walkMatrix(\@arrgraphics, \@probenames);

#walk the Nx60 matrix by cols
#for pos=1..60, find probes w/mm at pos and print avg rval. do same for probes w/match
sub walkMatrix{
	my($aref, $proberef) = @_;
	my @matchprobes = ();
	my @mmatchprobes = ();
	my $match=0;
	my $mmatch=0;
	print "position\tavgRval_mismatch\tavgRval_mismatchSE\tnumSeq_mismatch\tavgRval_match\tavgRval_matchSE\tnumSeq_match\n";
	for (my $i=0; $i<60; $i++){
		for (my $j=0; $j<= $#$aref; $j++){
			if ($aref->[$j][$i] eq '|') {
				$match++;
				push @matchprobes, $proberef->[$j];
			} else{
				$mmatch++;
				push @mmatchprobes, $proberef->[$j];
			}
		}
		#process col j
		#print "match=$match mismatch=$mmatch\n";
		#print "mm=@mmatchprobes\n";
		#print "m=@matchprobes\n";
		my ($resm,$resmse) = avgRvalByProbes(\@matchprobes);
	#	print "---\n";
		my ($resmm, $resmmse) = avgRvalByProbes(\@mmatchprobes);
		print "$i\t$resmm\t$resmmse\t$mmatch\t$resm\t$resmse\t$match\n";
		#clear vars
		$match=0; $mmatch=0; 
		@matchprobes = ();
		@mmatchprobes = ();
	}
}

sub avgRvalByProbes{
	my($aref) = @_;
	my $sum= 0;
	my $i;
	my $avg;
	my $sesum=0;
	my $se;
	#print "----call by @$aref\n";
	#return 0 if scalar (@$aref) == 0;
	for ($i=0; $i <= $#$aref; $i++){
		#print "$aref->[$i]\t$db{$aref->[$i]}\n";
		$sum += $db{$aref->[$i]};
	}
	$avg = $sum/$i;

	for ($i=0; $i<= $#$aref; $i++){
		$sesum += ($db{$aref->[$i]} - $avg)**2;
	}
	#print $sesum,"\n";
	$se = sqrt($sesum/($i-1))/sqrt($i);
	return($avg,$se);
}

sub printMatrix{
	my($aref, $proberef) = @_;
	for(my $j=0;$j<= $#$aref; $j++){
		for (my $i=0; $i<60; $i++){
			print $aref->[$j][$i]," ";
		}
		print "$proberef->[$j]\n";
	}
}
#probename => rvalue
sub builddb {
	open INPUT, "probe_rvalues.txt" or die "cannot open rvalues\n";
	while (<INPUT>){
		next if /^#/;
		chomp;
		my @data = split(/\t/,$_);
		$db{$data[0]} =$data[1];
	}
	close INPUT;
}
#get the number of actual matches at beg and end
#file1 (f1) is the probe, file2 is the genbank file
sub recompute{
	my($file1,$file2,$f1start,$f1end,$f2start,$f2end,$graphicref) = @_;
	my @graphic = split(//,$$graphicref); 
	my $match=0;
	my $mismatch=0;
	my $probeprefix='./probefiles/';
	my $gbprefix = './gbfiles/';
	my $oldsep = $/;
	$/="\n";
	open(FPROBE, "$probeprefix$file1") or die "cannot open probe file\n";
	my @file1 = <FPROBE>;
	close FPROBE;
	shift @file1; #lose the fasta line
	my $tmpprobe = join('', @file1);
	$tmpprobe =~ s/\n//ig;
	@file1 = split(//, $tmpprobe);
	open(FGB, "$gbprefix$file2") or die "cannot open genbank file\n";
	my @file2 = <FGB>;
	close FGB;
	shift @file2;
	my $tmp = join('', @file2);
	$tmp =~ s/\n//ig;
	@file2 = split(//, $tmp);
	#any more matches at beg?
	#note case where probe is longer than gbfile at beg
	# probe: actgactgactg
	# gb:       gactgactgaaaaa
	if ($f1start != 1) {
		#array index starts at 0, sim output starts at 1
		#subtract 1 to get into perl corrds, subtract another to get pos before they start matching
		my $i=$f1start-2; my $j=$f2start-2;
		for($i,$j; ($i>=0 && $j>=0); $i--,$j--){
			#print "$i, $j\n";
			#print "$file1[$i]  $file2[$j]\n";
			if ($file1[$i] eq $file2[$j]){
				$match++;
				unshift @graphic, "|";
			} else {
				$mismatch++;
				unshift @graphic, "x";
			}
		}
		#in thise case, probe starts earlier than gb file
		#unlikely to happen
		if (($j==0) && ($i!=0)){
			#assume all mismatches
			$mismatch += $i; 
			unshift @graphic, "x" x $i;
		}
	}
	#any matches at end?
	if ($f1end != 60){
		#array index starts at 0, sim output starts at 1
		my $i=$f1end; my $j=$f2end;
		for($i,$j; ($i<60 && $j<=$#file2); $i++,$j++){
			#print "nums $i,$j\n";
			#print "vals $file1[$i] eq $file2[$j]\n";
			if ($file1[$i] eq $file2[$j]){
				$match++;
				push @graphic, "|";
			} else {
				$mismatch++;
				push @graphic, "x";
			}
		}
		if ($j>$#file2 && $i<60){
			$mismatch += 60-$i;
			push @graphic, "x" x (60-$i);
		}
	}
	#reset record separator
	$/=$oldsep;
	my $newgraphic= join("",@graphic);
	#print "$newgraphic" . length($newgraphic),"\n";
	return($match,$mismatch,$newgraphic);
}
#input is a ref to array of arrays
sub build_pos_report{
	my($refarray) = shift;
	#two arrays of length 60
	my @match= ();
	my @mismatch=();
	#iterate over all probes
	foreach my $i (@$refarray){
		#iterate over len of probe (60)
#		foreach my $j (@$i){
#			print "$j";
#		}
		for (my $k=0; $k<=$#$i; $k++){
			#print "$k:${$i}[$k]";
			if (${$i}[$k] eq '|') {
				$match[$k]++;
			} else {
				$mismatch[$k]++;
			}
		}
		#print "\n";
	}
	
	for (my $i=0; $i<=$#match; $i++){
		#print "index $i has count $match[$i]\n";
		print "$i, $match[$i]\n";
	}
}
