#!/usr/bin/perl -w

use strict;
unless(@ARGV==1){
	print <<EOH;
	usage $0 <file with qvalues>
		$0 dog_all_qvals_sorted.txt
	
	implements the reordering procedure for BH fdr calc. output
	comes out in backwards order (last line, last file; next to last line, last file...
	so i will resort based on index keys again
EOH
exit(1);
}

opendir(DIR, "./unsort1/") or die "cannot open dir\n";
my @files = grep{ /uspl\d*/ } readdir(DIR);
@files = sort @files;
closedir(DIR);
my @files1 = reverse @files;
#print "f1=@files1","\n";

my ($i,$j);
my $tmpvar;
foreach my $i (@files1){
	open(INPUT, "./unsort1/$i") or die "cannot open file $i\n";
	my @bigarray = <INPUT>;
	close(INPUT);
	#print "size of array is ", scalar @bigarray, "\n";
	#start at bottom and reorder in incres size
	for($j=$#bigarray; $j >=0; $j--) {
		#print "array idx=$j","val is $bigarray[$j]\n";
		#last line of last file
		#print "i=$i\n";
		if ($j==$#bigarray &&  $i eq $files1[0]){
			#print "proc first file\n";
			print $bigarray[$j];
			next;
		} elsif ($j==$#bigarray ){
		#last line of every other file
			#print "last line\n";
			my $nextguy=(split(/\t/,$tmpvar))[3];
			chomp($nextguy);
			my $thisguy=(split(/\t/,$bigarray[$j]))[3];
			chomp($thisguy);
			if ( $nextguy < $thisguy){
				#set this guy's qval to nextguy's pval
				my @t = split(/\t/,$bigarray[$j]);
				$bigarray[$j]="$t[0]\t$t[1]\t$t[2]\t".(split(/\t/,$tmpvar))[3];
				#print "next=";
				print $bigarray[$j];
				#$bigarray[$i]=$bigarray[$i+1];
			} else {
				#otherwise just print cur qval
				#print "cur=";
				print $bigarray[$j];
			}
			next;
		}
		my $nextguy=(split(/\t/,$bigarray[$j+1]))[3];
		chomp($nextguy);
		my $thisguy=(split(/\t/,$bigarray[$j]))[3];
		chomp($thisguy);
		#print "$nextguy\t|\t$thisguy\n";	
		if ( $nextguy < $thisguy){
			#set thisguy's qval to nextguy's pval
			my @t = split(/\t/,$bigarray[$j]);
			$bigarray[$j]="$t[0]\t$t[1]\t$t[2]\t".(split(/\t/,$bigarray[$j+1]))[3];
			#print "next=";
			print $bigarray[$j];
			#$bigarray[$i]=$bigarray[$i+1];
		} else {
			#otherwise just print cur qval
			#print "cur=";
			print $bigarray[$j];
		}
	}
	#save last line into tmp variable
	$tmpvar = $bigarray[0];
	#print "tmpvar=$tmpvar\n";
}
