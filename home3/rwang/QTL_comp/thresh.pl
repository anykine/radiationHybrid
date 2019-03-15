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
	open(INPUT, $ARGV[0]) or die "cannot open file\n";
	while(<INPUT>){
		my @linedata = split(/\t/);
		#only if LOD is greater than this
		print $_ if ($linedata[4] >= $ARGV[1])
	}
