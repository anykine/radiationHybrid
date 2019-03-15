#!/usr/bin/perl -w
# transmogrify database files w/100+ columns into just 10 cols

unless (@ARGV) {
	print "usage $0 <input file>\n";
}
open(INPUT, "$ARGV[0]") || die "cannot open file\n";

while (<INPUT>) {
	my ($chrom, $chrindex, $marker, $copy0, $copy1, $copy2, $alias, $marker_start, $marker_end, @vector) = split/\t/;
	my $output = join("", @vector);
	$chrom =~ s/chr//;
	print "$chrom\t$chrindex\t$marker\t$copy0\t$copy1\t$copy2\t$alias\t$marker_start\t$marker_end\t$output";
#	print "$output\n";
}
