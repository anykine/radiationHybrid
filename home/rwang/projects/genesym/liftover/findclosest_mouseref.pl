#!/usr/bin/perl -w

$t="\t";
$n="\n";
#reference will be the mouse probes because it is the shortest list
# first read in human and store as hash by chromosome
%pn=();
$file="allprobeinfo.txt";
open(HANDLE, $file);
while(<HANDLE>) {
	chomp $_;
	($id, $pn, $gn) =split ("\t", $_);
	$pn{$id}{probe}=$pn;
	$pn{$id}{gene}=$gn;
}

%hum=();
$file="hum_probes_as_mouse2.txt";
open(HANDLE,$file);
while(<HANDLE>) {
	chomp $_;
	($chr, $start, $end, $index	)=split( "\t", $_);
	push ( @{$hum{$chr}{start}}, $start );
	push ( @{$hum{$chr}{index}}, $index );
	push ( @{$hum{$chr}{probe}}, $pn{$index}{probe} );
	push ( @{$hum{$chr}{gene}},  $pn{$index}{gene}  );

}
close(HANDLE);


print "mouse_probe_num\tmouse_probe\tmouse_gene\thuman_probe_num\thuman_probe\thuman_gene\tchr\tmstart\thstart\n";

$file="master_probe_info.txt";
open(HANDLE, $file);
while(<HANDLE>) {
	chomp $_;
	($ID, $probe, $chr, $start,$sg,$sys,$uni,$ll,$ch,$cyto,$unign,$ugs)= split ("\t", $_);
	unless ($chr=~/M/) { 
		$length=scalar @{$hum{$chr}{start}}; 
		for ($i=1; $i< $length; $i++ ) 
		{
			if ( ($start-${$hum{$chr}{start}}[$i-1])>=0 &&  ($start-${$hum{$chr}{start}}[$i])<=0 )
			{
				if (abs($start-${$hum{$chr}{start}}[$i-1]) <  abs($start-${$hum{$chr}{start}}[$i])  ) {
					print $ID.$t.$probe.$t.$ugs.$t.${$hum{$chr}{index}}[$i-1].$t.${$hum{$chr}{probe}}[$i-1].$t.${$hum{$chr}{gene}}[$i-1].$t.$chr.$t.$start.$t.${$hum{$chr}{start}}[$i-1].$n;
				}
				else {
					print $ID.$t.$probe.$t.$ugs.$t.${$hum{$chr}{index}}[$i].$t.${$hum{$chr}{probe}}[$i].$t.${$hum{$chr}{gene}}[$i].$t.$chr.$t.$start.$t.${$hum{$chr}{start}}[$i].$n;
				}
				last;
			}
		}
	}
}
close(HANDLE);

