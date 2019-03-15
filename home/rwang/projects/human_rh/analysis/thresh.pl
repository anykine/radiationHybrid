#!/usr/bin/perl -w

#threshold file above lod
#assume format is:
#geneID[1-20977], markerID[1-15822], alpha, mu, LOD
unless (@ARGV == 2){
	print <<EOH;
	usage $0 <file to threshold> <threshold>
EOH
exit(0);
}
@seq = 1..24;
foreach $i (@seq){
	$file = "output_lin" . $i . ".dat";
	print "$file\n";
	open(INPUT, $file) or die "cannot open file\n";
	while(<INPUT>){
		my @linedata = split(/\t/);
		#only if LOD is greater than this
		print $_ if ($linedata[4] > $ARGV[1])
	}
}
