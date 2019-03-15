#!/usr/bin/perl -w
#quickie script, parse ilmn synonyms col ilmn_ref8 into rows

open(INPUT, "ilmn4split.txt") or die "cannot open file\n";
<INPUT>;
while(<INPUT>){
	my @data = split(/\t/);
	my @syns = split(/;/, $data[12]);
	next if $data[12] =~ /^\s+$/;
	foreach my $i (@syns){
		chomp($i);
		print "$data[2]\t$data[6]\t$i\n";
	}

}
