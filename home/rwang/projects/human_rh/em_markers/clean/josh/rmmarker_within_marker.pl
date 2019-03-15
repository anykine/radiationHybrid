#!/usr/bin/perl -w
#
$file="allg3.tbl";
use Data::Dumper;

#sts_name    g3_hybrid_scores    alias   trueName    identNo Chrom   chromStart  chromEnd    m_order
%hsh=();
open(HANDLE,$file);
while(<HANDLE>) {
	chomp $_;
	($sts_name, $g3_hybrid_scores, $alias, $trueName, $identNo, $Chrom, $chromStart, $chromEnd, $m_order) = split("\t", $_); 
	$hsh{$sts_name}={'g3_hybrid_scores'=>$g3_hybrid_scores, 'alias'=>$alias, 'trueName'=> $trueName, 'identNo'=>$identNo, 'Chrom'=>$Chrom, 'chromStart'=>$chromStart,'chromEnd'=> $chromEnd, 'm_order'=>$m_order};
	#print $sts_name, "\t",  $g3_hybrid_scores, "\t",  $alias, "\t", $trueName, "\t", $identNo, "\t",  $Chrom, "\t", $chromStart, "\t", $chromEnd, "\t", $m_order, "\n";
}
close(HANDLE);

#print Dumper (\%hsh);
@missing=();

foreach $el (sort keys %hsh) { 

	foreach $el2 (sort keys %hsh) {
		if (exists $hsh{$el}{Chrom} && exists $hsh{$el2}{Chrom} && $el ne $el2 && ($hsh{$el}{Chrom} eq $hsh{$el2}{Chrom}) ){

			if (     ($hsh{$el}{chromStart} >= $hsh{$el2}{chromStart} ) && $hsh{$el}{chromEnd} <= $hsh{$el2}{chromEnd} ){
				$hsh{$el}=0;
				#				{'g3_hybrid_scores'=> 0, 'alias'=> 0, 'trueName'=> 0, 'identNo'=>0, 'Chrom'=>0, 'chromStart'=>0,'chromEnd'=> 0, 'm_order'=>0};
				#		print $el, "\n";
			}
		
		}

	}
}
print "\n";

foreach $el3 (sort keys %hsh) {

print $el3, "\t", $hsh{$el3}{g3_hybrid_scores}, "\t", $hsh{$el3}{alias}, "\t", $hsh{$el3}{trueName}, "\t", $hsh{$el3}{identNo}, "\t",$hsh{$el3}{Chrom} , "\t", $hsh{$el3}{chromStart} , "\t", $hsh{$el3}{chromEnd} , "\t", $hsh{$el3}{m_order} , "\n" ;

}
