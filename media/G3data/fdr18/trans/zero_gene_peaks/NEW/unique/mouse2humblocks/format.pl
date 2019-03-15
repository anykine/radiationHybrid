#!/usr/bin/perl -w
#
# for a file with: chr pos1 pos2
# this reformats so that pos1 < pos2
unless (@ARGV==1){
	print "usage: $0 <mus2hum_zerogene_blocks_fdr30.txt\n";
	print "formats file so that pos1 < pos 2\n";
	exit(1);
}

open(INPUT, $ARGV[0]) || die;
#open(INPUT, "mus2hum_zerogene_blocks_fdr30.txt") || die;
while(<INPUT>){
	next if /^#/; chomp;
	my ($chr, $p1, $p2, @a) = split(/\t/);
	print $chr,"\t";
	if ($p1 < $p2){
		#print "$p1\t$p2\n";
		print "$p1\t$p2\t", join("\t", @a),"\n";
	} else {
		print "$p2\t$p1\t", join("\t", @a),"\n";
		#print "$p2\t$p1\n";
	}
}
