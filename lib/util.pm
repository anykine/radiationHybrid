# read a file and return it as an array
sub get_file_data {
	my($filename) = @_;
	my @data = ();
	use strict;
	use warnings;
	unless ( open(FH, $filename) ) {
		print STDERR "Cannot open file: $filename\n\n";
		exit;
	}
	@data = <FH>;
	close FH;
	return @data;
}

#convert a string to number
sub atoi{
	my $t;
	foreach my $d (split(//, shift())){
		$t = $t*10+$d;
	}
}

1
