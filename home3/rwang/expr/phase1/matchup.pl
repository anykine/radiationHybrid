#!/usr/bin/perl -w
#
# check if I renamed cols correctly in g3rhset...clean.csv, clean1.csv
# the clean.csv file is median normalized, so use this
#
# reorder clean.csv into RHserver order
use strict;
use Data::Dumper;

#globals
my %mapping = ();  #array to rh number
my %rhorder = ();  #a1 = 1,...a40=40, b1=84...

#
# testing g3rhset_combined_genespring_clean versus clean1
#
get_mapping();
my @orderofarrays = test_mapping();

#
#reorder my columns
#
my @vals = sort byfile (values %mapping);

# 
# map rh# -> output column order
#
my $count=0;
foreach (@vals){
	$rhorder{$_} = $count++;
}
#debug print out
#foreach (@vals){
#	print "$_ => $rhorder{$_}\n";
#}

#foreach (@orderofarrays){
#	push @finalmap, $rhorder{ $mapping{$_} };
#}
open(INPUT, "g3rhset_combined_genespring_clean.csv")||die "cannot open array data\n";
<INPUT>; #skip header
#print header
print "name\t", join("\t", @vals), "\n";
while(<INPUT>){
	chomp;
	my @line = split(",");
	#print name and shift off array
	print $line[0],"\t"; 
	shift @line;
	#finish mapping stuff, col1 is probe
	my @reordercols = ();
	#complicated remapping of columns into correct output order
	for (my $i=0; $i<=$#line; $i++){
		#$reordercols[$i] = $line[ $rhorder{ $mapping{ $orderofarrays($i) } } ];
		#print "orderarrays =  $orderofarrays[$i]\n";
		#print "mapping = $mapping{ $orderofarrays[$i] }\n";
		#print "rhorder = $rhorder{ $mapping{ $orderofarrays[$i] } }\n" ;
		$reordercols[ $rhorder{ $mapping { $orderofarrays[$i] } } ] = $line[$i];
	}
	print join("\t", @reordercols), "\n";

}

#natural sort: beautiful little routine thanks to perlmonks
sub byfile {
				my @a = split /(\d+)/, $a;
				my @b = split /(\d+)/, $b;
				my $M = @a > @b ? @a : @b;
				my $res = 0;
				for (my $i = 0; $i < $M; $i++) {
								return -1 if ! defined $a[$i];
								return 1 if  ! defined $b[$i];
								if ($a[$i] =~ /\d/) {
												$res = $a[$i] <=> $b[$i];
								} else {
												$res = $a[$i] cmp $b[$i];
								}
								last if $res;
				}
				$res;
}
sub test_mapping{
	#arrays
	open(INPUT, "head2")||die "cannot open ilmn";
	my $ilmn = <INPUT>;
	chomp $ilmn;
	close(INPUT);
	#rhnumbers
	open(INPUT, "head1")||die "cannot open rhs";
	my $rh = <INPUT>;
	chomp $rh;
	close(INPUT);
	my @ilmn = split(",", $ilmn);
	my @rh = split(",", $rh);
	for (my $i = 0; $i<= $#ilmn; $i++){
		#print "$ilmn[$i]\n";
		if ($mapping{$ilmn[$i]} eq $rh[$i]){
			#print "$ilmn[$i]\t$rh[$i]\n";
		} else {
			#print "$ilmn[$i] no match $rh[$i]\n";
		}

	}
	return @ilmn
}
sub get_mapping {
	open(INPUT, "ilmn_G3_samplesheet_80cells_62_66correct.csv") || die "cannot open sample sheet";
	for (my $i = 0; $i<9; $i++){
		<INPUT>
	}
	while(<INPUT>){
		chomp;
		my @line = split(",");
		my $str = $line[5]."_".$line[6];
		#print "$line[3]\n";
		my $v = $line[3];
		#print "$str = $v\n";
		$mapping{$str} = $v;
	}
}

