#!/usr/bin/perl -w
# find the max cis peak per gene in a simple way 

use strict;
use Data::Dumper;

unless (@ARGV==1){
	print <<EOH;
	usage $0 <file>
	Find the max cis peak per gene
EOH
exit(1);
}

my %cis=();
open(INPUT, $ARGV[0]) || die "error $!";
while(<INPUT>){
	chomp; next if /^#/;
	my @d  = split(/\t/);
	if (defined $cis{$d[0]}){
		if ($d[5] > $cis{$d[0]}{nlp} ){
			$cis{$d[0]} = {marker=>$d[1], 
										mu => $d[2],
										alpha=>$d[3],
		 								nlp=>$d[5],
										r=>$d[4] }
		}
	} else {
		$cis{$d[0]} = {marker=>$d[1], 
										mu => $d[2],
										alpha=>$d[3],
		 								nlp=>$d[5],
										r=>$d[4] };
	}
}

## output
for my $i (sort {$a<=>$b} keys %cis){
	#gene | marker | alpha | r| nlp
	print join("\t", $i, $cis{$i}{marker},
	 $cis{$i}{mu},
	 $cis{$i}{alpha},
	 $cis{$i}{r},
	 $cis{$i}{nlp}
	),"\n";
}
