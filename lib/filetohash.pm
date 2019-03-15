package file2hash;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&read_g3header &get_g3record);
use strict;
use warnings;

#constants
use Data::Dumper;

sub file2hash{
	my ($aref, $col, $file, $sep) = @_;
	@cols = (sort keys %$col);
	open(INPUT, $file) || die "cannot open $file";
	while(<INPUT>){
		my @d = split(/$sep/);
		foreach my $i (@cols){
			$aref->{$col->{$i}} = $d[$i];
		}
	}
}
1;

=head1 NAME

file2hash - read a file of columns into a hash. You specify the file format
and the hash to read into.

=head1 SYNOPSIS

 $aref is a reference to a hash (ie the hash you want to fill)
 
 #specify the columns of interest and their name in the hash
 $col=(
	0=>id,
	1=>start,
	2=>end
 )

 $sep="\t";
 $file="mus2hum.txt";

 file2hash($aref, $col, $file, $sep);
 

=head1 AUTHOR

Richard Wang

