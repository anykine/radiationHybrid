#!/usr/bin/perl -w

#ghetto script to search for peaks with G3's in it

open(INPUT, "../markers_with_g3.txt") or die "cannot open input $!\n";
@G3list = <INPUT>;
close INPUT;
open(OUTPUT, ">scanTNGandG3.out") or die "cannot open output\n";

#for all chunks
for ($i=0; $i<35; $i++){
	$a = pad($i);
	#print "$a\n";
	$filename = "chunk" . $a . ".chisq";
	open(READFILE, $filename) or die "canot open chunk$i\n";
	#@input = <READFILE>;
	while ($input = <READFILE>){
		#for 10million rows
			#print "chunk $i \n";
			#print "chunk $i row $j\n";
			#compare each against g3list
			for ($k=0; $k<$#G3list; $k++) {
				#print "chunk $i row $j looking for g3 $k\n";
				#if ($input[$j] =~ /m1=$G3list[$k]/)	{
				if (($input =~ /m1=$G3list[$k]/)&&($input =~ /e-\d\d/))	{
					#print "found! chunk$i $G3list[$k]\n";
					print OUTPUT "chunk$i $G3list[$k]\n";
				} #if
			}#for
	} #while
	close READFILE;
}
close OUTPUT;


sub pad {
	my ($in) = @_;
	if (length($in) < 2){
		return "0".$in;
	} else {
		return $in;
	}


}
