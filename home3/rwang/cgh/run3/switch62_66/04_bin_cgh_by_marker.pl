#!/usr/bin/perl -w
use Data::Dumper;
$t="\t";
$n="\n";

# bin the cgh data using marker positions as a scaffold...quantify the cgh data based on 10 closest probes to a pcr marker

%cgh=();
$file="batch_swi_smoothed1.txt";

open(HANDLE, $file);
$header=<HANDLE>; chomp $header;
@hd = split ("\t", $header); shift @hd; shift @hd; shift @hd;
foreach $cell (@hd) {
	$cell =~ s/^c//g;
	$cell =~ s/^c//g;
	push (@hda, $cell); 
}
# prints headers
#need new index as some pcr markers won't have ten neighboring cgh probes
print  "oldindex".$t."newindex".$t."chr".$t."start".$t."stop".$t;

#two arrays for cgh coerced to pcr format and  and original pcr data
@cgh=@hda; @pcr=@hda;

#new header will have columns for cgh coerced to pcr format and original pcr data
for ($i=0; $i < (scalar @cgh)-1; $i++ ) { $cgh[$i] =~ s/^/cgh/g;	print $cgh[$i].$t; }
$cgh[$#cgh] =~ s/^/cgh/g; print $cgh[$#cgh].$t;

for ($i=0; $i < (scalar @pcr)-1; $i++ ) { $pcr[$i] =~ s/^/pcr/g;  print $pcr[$i].$t; }
$pcr[$#pcr] =~ s/^/pcr/g;  print $pcr[$#pcr].$n;

#----

while (<HANDLE>) {
	chomp $_;
	@line = split ("\t", $_);  
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
	

# number of cgh probes per chromosome
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
$chrlength{chr19} = scalar @{$cgh{chr19}{start}}; 		$chrlength{chr20} = scalar @{$cgh{chr20}{start}};   
$chrlength{chr21} = scalar @{$cgh{chr21}{start}};  		$chrlength{chr22} = scalar @{$cgh{chr22}{start}};   
$chrlength{chrX}  = scalar @{$cgh{chrX}{start}}; 			$chrlength{chrY}  = scalar @{$cgh{chrY}{start}};

# will be hg18 retention data 
# now use the marker position as a scaffold 
$file="hg18_retention_v2.txt"; 
open(HANDLE,$file);
$junk=<HANDLE>;

$index2=1; # new index
while(<HANDLE>) {
	chomp $_;
	
	@line = split( "\t", $_);

	$index = shift @line;
	$chrm = shift @line;
	$start = shift @line;
	$end = shift @line;
	
	#for each pcr marker get the ten neighboring cgh probes  -- will have array of ten closest cgh probes for each marker
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
	if ( (scalar @{$closest[0]}) > 0 ){	
					print    $index.$t.$index2.$t.$chrm.$t.$start.$t.$end.$t;
			for ($m=0; $m< scalar @hda; $m++) {
				if ( avg(\@{@{$closest[$m]}}) > 0.176 ) { print "1".$t; }  else  { print "0".$t; } 
			}	
	
			for ($o=0; $o<scalar @hda; $o++) {
				if ( (scalar @hda)-$o==1) { 
				print $line[$hda[$o]-1].$n;
				}
				else { print $line[$hda[$o]-1].$t;}
			}		

	$index2++;
	}
	
}
close(HANDLE);


sub avg {
	my $result;
	my $ar = shift;
	foreach (@$ar) { $result += $_ }
	return $result / scalar(@$ar);
}
