#!/usr/bin/perl -w

use strict;
unless(@ARGV==2){
	print <<EOH;
	usage $0 <directory> <fileprefix containing qvalues>
		$0 <qvals> <transq>
	
	Efficient implementation the reordering procedure for BH fdr calc. Output
	comes out in backwards order (last line, last file; next to last line, last file...
	so i will resort based on index keys again. This reads in one file at a time,
	starting with the last so only keeps 1 file in memory at a time.

	Notes for chris data:
	Input files are in decres order of qval with file1 fdr's bigger than file2...
	and within file1 the pvals are decresing
EOH
exit(1);
}

opendir(DIR, "$ARGV[0]") or die "cannot open dir\n";
my @files = grep{ /$ARGV[1]\d*/ } readdir(DIR);
my @files1 = sort @files;
closedir(DIR);
#print "f1=@files1","\n";
my ($i,$j);
my $tmpvar;
foreach my $i (@files1){
	open(INPUT, "./$ARGV[0]/$i") or die "cannot open file $i\n";
	my @bigarray = <INPUT>;
	close(INPUT);
	#print "size of array is ", scalar @bigarray, "\n";
	#start at top and reorder in decres size
	for($j=0; $j <= $#bigarray; $j++) {
		#print "array idx=$j","val is $bigarray[$j]\n";
		#print last (largest) element
		#print "i=$i\n";
		if ($j==0 &&  $i eq $files1[0]){
			#print "proc first file\n";
			print $bigarray[$j];
			next;
		} elsif ($j==0){
		#first line of every other file
			#print "last line\n";
			my $prevguy=(split(/\t/,$tmpvar))[1];
			chomp($prevguy);
			my $thisguy=(split(/\t/,$bigarray[$j]))[1];
			chomp($thisguy);
			if ( $prevguy < $thisguy){
				#set this guy's qval to prevguy's pval
				my @t = split(/\t/,$bigarray[$j]);
				$bigarray[$j]="$t[0]\t".(split(/\t/,$tmpvar))[1];
				print $bigarray[$j];
				#$bigarray[$i]=$bigarray[$i+1];
			} else {
				#otherwise just print cur qval
				#print "cur=";
				print $bigarray[$j];
			}
			next;
		}
		my $prevguy=(split(/\t/,$bigarray[$j-1]))[1];
		chomp($prevguy);
		my $thisguy=(split(/\t/,$bigarray[$j]))[1];
		chomp($thisguy);
		if ( $prevguy < $thisguy){
			#set thisguy's qval to prevguy's pval
			my @t = split(/\t/,$bigarray[$j]);
			$bigarray[$j]="$t[0]\t".(split(/\t/,$bigarray[$j-1]))[1];
			print $bigarray[$j];
			#$bigarray[$i]=$bigarray[$i+1];
		} else {
			#otherwise just print cur qval
			#print "cur=";
			print $bigarray[$j];
		}
	} #for loop
	#save last line into tmp variable
	$tmpvar = $bigarray[$#bigarray];
	#print "tmpvar=$tmpvar\n";
}# for loop
