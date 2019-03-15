#!/usr/bin/perl -w

# expand the corners to create list of all points
unless (@ARGV==1){
	print <<EOH;
	usage $0 <file of coords>

	Take the speck/vert/horiz streak list and expand
	to create a list of points for purging of chi-sq
	data.
EOH
exit(1);

}
open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
while(<INPUT>){
	my @data = split(/\t/);
	for (my $i=$data[0]; $i<=$data[2]; $i++){
		for (my $j = $data[1]; $j<=$data[3]; $j++){
			print "$i\t$j\n";			
		}
	}
}
