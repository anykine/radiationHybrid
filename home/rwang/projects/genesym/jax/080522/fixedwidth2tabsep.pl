#!/usr/bin/perl -w

use strict;
use Data::Dumper;

unless (@ARGV >= 1){
	print <<EOH;

	Handy for fixed width data where you want to extract rows.
	usage $0 <file> <optional comma-sep list of positions>
EOH
exit(1);
}
open(INPUT, $ARGV[0]) or die "cannot open file for read\n";

my @offsets=();

if($ARGV[1]){
	@offsets = split(/,/, $ARGV[1]);
}
#cut at columns 20, 44, 68...)
#calculates the unpack A19, An, An...

#calc the template (e.g., A6 A14, A2...) based on 
#columns you specify
#my $fmt = cut2fmt(20, 44, 68, 100, 133, 158, 182, 193, 204 );
my $fmt = cut2fmt(@offsets);

while(<INPUT>){
	next if /^#/;
	my @data = unpack($fmt, $_);
	foreach my $i(@data){
		$i =~ s/\s+//;
	}
	print join("\t", @data), "\n";
	#print Dumper(\@data);
}
# right out of perl cookbook
sub cut2fmt {
	my(@positions) = @_;
	my $place;
	my $template   = '';
	my $lastpos    = 1;
	foreach $place (@positions) {
		$template .= "A" . ($place - $lastpos) . " ";
		$lastpos   = $place;
	}
	$template .= "A*";
	return $template;
}

