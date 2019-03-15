#!/usr/bin/perl -w
# changes the first line of illumina expression output
# to the format expected by bioconductor/beadarray
#  i.e., AVG_Signal-1, AVG_Signal-2...
open(INPUT, $ARGV[0]) or die "cannot open file\n";

while(<INPUT>){
	s/"//ig;
	@data = split(/,/);
	#parse the header
	for ($i=0; $i<=$#data; $i++) {
		#$data[$i] =~ s/"//;
		#print $data[$i],"\n";
		if ($data[$i] =~ /-(\d+_\w)/) {
			#print $1, "\n";
			push @arrayorder, $1 if ($1 ne $arrayorder[$#arrayorder]);
			$index = $#arrayorder + 1;
			$data[$i] =~ s/-(\d+_\w)/-$index/;
			#print "$data[$i]\n";
		}
	}
}

$c=1;
foreach $i(@arrayorder){
	print "$c\t$i\n";
	$c++;
}
$var = @arrayorder;
#print $var,"\n";
$string = join(",", @data);
print $string;
