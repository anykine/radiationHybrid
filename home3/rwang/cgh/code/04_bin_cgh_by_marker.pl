#!/usr/bin/perl -w
use Data::Dumper;
$t="\t";
$n="\n";

# bin the cgh data using marker stop positions as a scaffold

%cgh=();
$file="smoothed_log_ratios_3.txt";

open(HANDLE, $file);
$header=<HANDLE>; chomp $header;
@hd = split ("\t", $header); shift @hd; shift @hd; shift @hd;
foreach $cell (@hd) {
	$cell =~ s/^0//g;
	$cell =~ s/^0//g;
	push (@hda, $cell); 
}
# prints headers
print  "oldindex".$t."newindex".$t."chr".$t."start".$t."end".$t."marker".$t;
@cgh=@hda; @pcr=@hda;

for ($i=0; $i < (scalar @cgh)-1; $i++ ) { $cgh[$i] =~ s/^/cgh/g;	print $cgh[$i].$t; }
$cgh[$#cgh] =~ s/^/cgh/g; print $cgh[$#cgh].$t;

for ($i=0; $i < (scalar @pcr)-1; $i++ ) { $pcr[$i] =~ s/^/pcr/g;  print $pcr[$i].$t; }
$pcr[$#pcr] =~ s/^/pcr/g;  print $pcr[$#pcr].$n;

#----

while (<HANDLE>) {
	chomp $_;
	@line = split ("\t", $_);  
	#($index, $chrm, $start, $stop, $a, $b, $c  ) = split ("\t", $_) ; 
	$chrm  = shift @line;
	$start = shift @line;
	$stop  = shift @line;
		push ( @{$cgh{$chrm}{start}}, $start );
		push ( @{$cgh{$chrm}{stop}}, $stop );
		for($j=0; $j < scalar @hda; $j++) { 
			push (@{$cgh{$chrm}{$j}}, shift @line );
		}
}
close(HANDLE);
	

	#modify for human - number of probes per chromosome
%chrlength=();
$chrlength{chr01} =  scalar @{$cgh{chr01}{start}};   	$chrlength{chr02}  = scalar @{$cgh{chr02}{start}};
$chrlength{chr03} =  scalar @{$cgh{chr03}{start}};   	$chrlength{chr04}  = scalar @{$cgh{chr04}{start}};
$chrlength{chr05} =  scalar @{$cgh{chr05}{start}};   	$chrlength{chr06}  = scalar @{$cgh{chr06}{start}};
$chrlength{chr07} =  scalar @{$cgh{chr07}{start}};   	$chrlength{chr08}  = scalar @{$cgh{chr08}{start}};
$chrlength{chr09} =  scalar @{$cgh{chr09}{start}};   	$chrlength{chr10} = scalar @{$cgh{chr10}{start}};
$chrlength{chr11} = scalar @{$cgh{chr11}{start}};    	$chrlength{chr12} = scalar @{$cgh{chr12}{start}};
$chrlength{chr13} = scalar @{$cgh{chr13}{start}};   	$chrlength{chr14} = scalar @{$cgh{chr14}{start}};
$chrlength{chr15} = scalar @{$cgh{chr15}{start}};   	$chrlength{chr16} = scalar @{$cgh{chr16}{start}};
$chrlength{chr17} = scalar @{$cgh{chr17}{start}};   	$chrlength{chr18} = scalar @{$cgh{chr18}{start}};
$chrlength{chr19} = scalar @{$cgh{chr19}{start}};   	$chrlength{chrX}  = scalar @{$cgh{chrX}{start}};
#print Dumper (\%cgh);





# will be hg18 retention data 
# now use the marker position as a scaffold 
$file="/home2/CGH_improved/first_run_stuff/first_run_main/mm7_retention.txt";
open(HANDLE,$file);
$junk=<HANDLE>;

$index=1; #index relative to original marker file
$index2=1; # new index
while(<HANDLE>) {
	chomp $_;
	
	@line = split( "\t", $_);
	
	$chrm = shift @line;
	$start = shift @line;
	$end = shift @line;
	$marker= shift @line;
	
	#jnk----
	$zeroes= shift @line;
	#----
	
	#for each pcr marker get the ten neighboring cgh probes  -- will have array of ten closest for each marker
	@closest=();
	for ($i=0; $i< scalar @hda; $i++) {
		@{$closest[$i]}=();
	}

	for ($i=4; $i < $chrlength{$chrm}; $i++)  { 	
		if ( ( ${$cgh{$chrm}{start}}[$i] <= ($end+$start/2) )   &&  ( ${$cgh{$chrm}{start}}[$i+1] >= ($end+$start)/2 )   ) {  
		
			for ($k=$i-4; $k<$i+6; $k++) {
					for ($m=0; $m< scalar @hda; $m++) {
						push @{$closest[$m]},	${$cgh{$chrm}{$m}}[$k];
					}				
			}
			last;	
		}
	}
#print scalar @ARGV.$n;
#print Dumper (\@closest);
	if ( (scalar @{$closest[0]}) > 0 ){	
		print    $index.$t.$index2.$t.$chrm.$t.$start.$t.$end.$t.$marker.$t;
			for ($m=0; $m< scalar @hda; $m++) {
				if ( avg(\@{@{$closest[$m]}}) > 0.176 ) { print "1".$t; }  else  { print "0".$t; } 
			}	
	
			for ($o=0; $o<scalar @hda; $o++) {
								push @{$closest[$m]},	${$cgh{$chrm}{$m}}[$k];
				if ( (scalar @hda)-$o==1) { 
				print $line[$hda[$o]-1].$n;
				}
				else { print $line[$hda[$o]-1].$t;}
			}		

	$index2++;
	}
	
	$index++;
}
close(HANDLE);


sub avg {
	my $result;
	my $ar = shift;
	foreach (@$ar) { $result += $_ }
	return $result / scalar(@$ar);
}


#	( $chrm, $start, $end, $marker, $zeroes, 
#	$c1,  $c2 , $c3 , $c4 , $c5 , $c6 , $c7 , $c8 , $c9 , $c10,	$c11, $c12, $c13, $c14, $c15, $c16, $c17, $c18, $c19, $c20,
#	$c21, $c22, $c23, $c24, $c25, $c26, $c27, $c28, $c29, $c30,	$c31, $c32, $c33, $c34, $c35, $c36, $c37, $c38, $c39, $c40,
#	$c41, $c42, $c43, $c44, $c45, $c46, $c47, $c48, $c49, $c50,	$c51, $c52, $c53, $c54, $c55, $c56, $c57, $c58, $c59, $c60,
#	$c61, $c62, $c63, $c64, $c65, $c66, $c67, $c68, $c69, $c70,	$c71, $c72, $c73, $c74, $c75, $c76, $c77, $c78, $c79, $c80,
#	$c81, $c82, $c83, $c84, $c85, $c86, $c87, $c88, $c89, $c90,	$c91, $c92, $c93, $c94, $c95, $c96, $c97, $c98, $c99, $c100 ) 
