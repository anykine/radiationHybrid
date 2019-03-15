#!/usr/bin/perl -w
# converts the file formats AVG.Signal-xxxxxxxx_A
# to the format used in R, beadarray package AVG.Signal-1
open(INPUT, $ARGV[0]) || die "cannot open file\n";
open(OUTPUT, ">$ARGV[0]"."out") || die "cannot open output\n";

%map = ('A'=>1, 'B'=>2, 'C'=>3, 'D'=>4, 'E'=>5, 'F'=>6, 'G'=>7, 'H'=>8);

while (<INPUT>){
	next unless /^"/;
	my @line = split(/,/);
	my $data;
	if (/^"TargetID/) {
		for (my $i=0; $i<=$#line; $i++){
			#print $line[$i],"\n";
			$line[$i] =~s/"//g;
			$line[$i] =~ s/-(\d+)_(\w)/-$map{$2}/;
			$data = join(",", @line);
		}
	}
	for (my $i=0; $i<=$#line; $i++){
		$line[$i] =~ s/"//g;
		$data = join(",", @line);
	}
	print OUTPUT "$data";
}
