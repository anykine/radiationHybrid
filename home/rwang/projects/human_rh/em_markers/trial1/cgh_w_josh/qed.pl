#!/usr/bin/perl -w

use Data::Dumper;

foreach $i (<rh_genotype_chr*.txt>){
	$i =~ s/rh_genotype_//ig;
	$i =~ s/\.txt//ig;
	print $i,"\n";
	$tmp = `wc -l rh_genotype_$i.txt`;
	chomp($tmp);
#	print $tmp,"\n";
	$i =~ s/chr//;
	$chr{$i} = (split(/\s/,$tmp))[0];
}
@mykeys = sort{$a<=>$b} keys %chr;
#print @mykeys;
#print Dumper(\%chr);

foreach $i (@mykeys){
for ($j=0; $j <= $chr{$i}; $j++){
	print "chr0".$i,"\n" if $i < 10;
	print "chr$i","\n" if $i>=10;
}

}
