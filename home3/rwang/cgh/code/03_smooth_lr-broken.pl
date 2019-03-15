#!/usr/bin/perl -w
$t="\t";
$n="\n";

#these two can change
$out = "smoothed_log_ratios.txt";
$raw = "batch_1_raw.txt";

$pos = "pos_in_genomeorder.txt";

`R $raw --no-save -q < 03b_smooth.R`;
`head -n 1 $raw > temp2`;
`cat temp2 temp1 > temp3`;
`paste $pos temp3 > $out`;
#`rm temp1 temp2 temp3`;

