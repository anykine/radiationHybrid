#!/usr/bin/perl -w

unless (@ARGV==2){
	print <<EOH;
	$0 <file to comp> <radius>

	remove the diagonal from chisq plots using 
	specified radius
EOH
exit(1);
}

open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	my @line = split(/\t/);	
	next if abs($line[0]-$line[1]) < $ARGV[1];
	print join("\t", @line);
}
