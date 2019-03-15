#!/usr/bin/perl -w
 
$t="\t";
$n="\n";
#cell_num is the number of cell lines for this batch
$file="/home2/CGH_improved/binned_unfixed3";
%all=();
open(HANDLE,$file);
$header=<HANDLE>; 
print $header;

chomp $header;
@heads=split ("\t", $header);
shift @heads; shift @heads; shift @heads; shift @heads; shift @heads; shift @heads;
$cell_num = (scalar @heads)/2;


while(<HANDLE>) {
	chomp $_;

#	(  $oldind, $newind, $chrm, $start, $end, $marker, $ca, 	$cb, $cc,  $pa,    $pb,   $pc) 
	@line = split( "\t", $_);
	
	$oldind = shift @line;
	$newind = shift @line;
	$chrm  = shift @line;
	$start = shift @line;
	$end  = shift @line;
	$marker = shift @line;
	push ( @{$all{oldindex}}, $oldind );
	push ( @{$all{newindex}}, $newind );
	push ( @{$all{chrm}}, $chrm );
	push ( @{$all{start}}, $start );
	push ( @{$all{end}}, $end );	
	push ( @{$all{marker}}, $marker ); 

	for($j=0; $j < 2*$cell_num; $j++) { 
			push (@{$all{$j}}, shift @line );
	}
}
close(HANDLE);

$len= scalar @{$all{newindex}};

for ($i=0; $i<4; $i++) { printa($i,0); }
for ($i=4; $i<($len-4); $i++) {	printa($i,1); }
for ($i=($len-4); $i<$len; $i++) {printa($i,0); }

sub printa {
	($i,$switch) = @_;


	print  ${$all{oldindex}}[$i].$t ;
	print  ${$all{newindex}}[$i].$t ;
	print  ${$all{chrm}}[$i].$t ;
	print  ${$all{start}}[$i].$t ;
	print  ${$all{end}}[$i].$t ;
	print  ${$all{marker}}[$i].$t ;
	#just print out cgh results
	for($j=0; $j < $cell_num; $j++) { 
			print ${$all{$j}}[$i].$t;
	}
	# fix pcr results 
	if ($switch==0) {
		for ($j=$cell_num; $j<((2*$cell_num)-1);$j++) { print ${$all{$j}}[$i].$t;}
			$b=((2*$cell_num)-1); print ${$all{$b}}[$i].$n; 
	}
	elsif ($switch==1) {
			for($name=$cell_num; $name<((2*$cell_num)-1); $name++) { checkcase($i,$name,3); print $t; }
			$b=((2*$cell_num)-1); checkcase($i, $b, 3); print $n; 
	}
}


sub checkcase {
	$flag=0;
	($i, $name, $test) = @_;
	
	if (${$all{$name}}[$i]==0 || ${$all{$name}}[$i]==2)  { 
		for ($j=$i-$test; $j<$i; $j++)  { if (${$all{$name}}[$j]==1) { $flag++;	} 	}
		for ($j=$i+1; $j<($i+$test+1); $j++) { if (${$all{$name}}[$j]==1) { $flag++;	}	}
	
		if ($flag == (2*$test) ) {print "1";}	
		elsif (${$all{$name}}[$i]==2) {print "2";}
		else {print "0";}  
	}
	
	elsif (${$all{$name}}[$i]==1 || ${$all{$name}}[$i]==2) { 
		for ($j=$i-$test; $j<$i; $j++) {  if (${$all{$name}}[$j]==0) { $flag++;	}	}
		for ($j=$i+1; $j<($i+$test+1); $j++) { if (${$all{$name}}[$j]==0) { $flag++; }	}

		if ($flag == (2*$test) ) { print "0";} 	
		elsif (${$all{$name}}[$i]==2) {print "2";}
		else {print "1";}
	}
}
