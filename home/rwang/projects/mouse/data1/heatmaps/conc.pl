#!/usr/bin/perl 

for ($i = 56; $i<111; $i++){
	$var = $var . "heatmap".$i.".txt ";
}

print $var;
`cat $var > hugeheat2.txt`;
