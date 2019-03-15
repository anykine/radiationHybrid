#!/usr/bin/perl -w
#
#use the ilmn list of hum ham genes to pick out some good ones
my %best = ();
sub load_ilmnbest{
	open(INPUT, "/home/rwang/hum_ham_detect90idx.txt") || die "cannot open file for read\n";
	while(<INPUT>){
		next if /^#/; chomp;
		my @d = split(/\t/);
		$best{$d[0]} = 1;
	}
}

sub filter_file{
	my($file) = @_;
	# genes are in first column	
	open(INPUT, $file ) || die "cannot find file $file\n";
	while(<INPUT>){
		next if /^#/; chomp;
		my @d = split(/\t/);
		print join("\t", @d),"\n" if defined ( $best{ $d[0]} );

	}
}


####### MAIN #########3
unless (@ARGV==1){
	print "usage: $0 <trans_peaks_FDR40.txt>\n";
	exit(1);
}


load_ilmnbest();
filter_file($ARGV[0]);
