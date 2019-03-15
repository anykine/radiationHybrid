#!/usr/bin/perl -w
#
use lib '/home/rwang/lib';
use g3datamanip;

unless (@ARGV==1){
	print <<EOH;
	usage $0 <marker>
		$0 11200

	Extract all genes' nlp and alpha value assoc with marker
EOH
exit(1);
}

sub get_human_data_by_marker{
	my ($marker) = @_;
	my %data = ();
	for (my $i = 1; $i<=20996; $i++){
		my %record = get_g3record($i, $marker);
		push @{$data{alpha}}, $record{alpha};
		push @{$data{nlp}}, $record{nlp};
	}
	return \%data;
}

### MAIN####

$dataref = get_human_data_by_marker($ARGV[0]);

for (my $i=0; $i<20996; $i++){
	print $dataref->{alpha}[$i], "\t"; 
	print $dataref->{nlp}[$i], "\n"; 
}
