#!/usr/bin/perl -w

# convert these files for comparison


sub filter{
	my $file = shift;
	open(OUTPUT, ">$file.txt") || die "err $!";
	open(INPUT, $file) || die "err $!";
	while(<INPUT>){
		chomp; next if /^#/;
		#print;
		my @d = split(/\t/);
		$d[0] =~ s/chrX/23/;
		$d[0] =~ s/chrY/24/;
		$d[0] =~ s/chr//;
		print OUTPUT join("\t", @d),"\n";
	}
	close(OUTPUT);
}

@files =  <*.pbed>;
#print @files;

foreach my $k (@files) {
	filter($k);
}
