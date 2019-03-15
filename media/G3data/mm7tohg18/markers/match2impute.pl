#!/usr/bin/perl -w
#
#match up the mouse_revloNN.txt file to the imputed locations
#
use strict;
use Data::Dumper;

unless (@ARGV==2){
	print <<EOH;
	usage $0 <file with imputatin> <file to match>
	 eg $0 mouse_revlo95_impute.txt mouse_revlo95.txt
EOH
exit(1);
}

#store imputed values, use mouse probe coords as key
my %impute=();
open(INPUT, $ARGV[0]) || die "cannot open file\n";
while(<INPUT>){
	next if not /^chr/;
	chomp;
	my @line= split(/\t/);
	my $k = join("\t", @line[0,1,2]);
	#print $k,"\n";
	shift @line;
	shift @line;
	shift @line;
	#print "pop=@line\n";
	$impute{$k} = join("\t",@line);
}
close(INPUT);
#print Dumper(\%impute);
#
#do the matchup
open(INPUT, $ARGV[1]) || die "cannot open file2\n";
while(<INPUT>){
	next if not /^chr/;
	chomp;
	print;
	print "\t";
	my @line = split(/\t/);
	my $k = join("\t", @line[0,1,2]);
	if (exists $impute{$k}){
		print $impute{$k},"\n";
	} else {
		print "\n";
	}
}
