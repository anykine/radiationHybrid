#!/usr/bin/perl -w
#
# average replicates, using inverted data set
use strict;
use Data::Dumper;

# average the inverted replicate tissues, id'd by number 
sub average_inverted{
	my %data=();
	open(INPUT, "GNF1Hdata_invert.txt") || die "cannot open replicate file";
	my $header = <INPUT>;
	# store all the data
	while(<INPUT>){
		chomp;next if /^#/;
		my @d = split(/\t/);
		my $tissue = shift @d;
		if (defined $data{$tissue}){
			# average values;
			my $temp = [ @d ];
			my $res = average_vectors($data{$tissue}, $temp);
			$data{$tissue} = $res;
		} else {
			$data{$tissue} = [ @d ];
		}
		#if ($counter++ == 2){
		#	output_vector($data{1});
		#	#print Dumper(\%data);
		#	return;
		#}
	}
	#output data
	print $header;
	for (my $tissue=1; $tissue<= 79; $tissue++){
		print $tissue,"\t";
		print join("\t", @{$data{$tissue}}),"\n";
	}
}

# average the two vectors
sub average_vectors{
	my ($vec1, $vec2)=@_;
	#print "line1=";
	#output_vector($vec1);
	#print "line2=";
	#output_vector($vec2);
	my $result = [];
	for (my $i=0; $i< scalar @$vec1; $i++){
		$result->[$i] =  ($vec1->[$i] + $vec2->[$i])/2;
	}
	#print "result=";
	#output_vector($result);
	return $result;
}

# diagnostic output of vector
sub output_vector{
	my $ref = shift;
	for (my $i=0; $i< scalar @$ref; $i++){
		print $ref->[$i],"\t";
	}
	print "\n";
}

# average duplicate genes
sub average_symbols{
	my %alldata=();
	open(INPUT, "GNF1Hdata_replicate_avg_symbol_sort.txt")||die "cannot open file";
	#open(INPUT, "t.sort")||die "cannot open file";
	my $header = <INPUT>;
	while(<INPUT>){
		next if /^#/; chomp; 
		my @d = split(/\t/);
		my $symbol =  shift @d;
		my $probe_id = shift @d; #not used

		#store data
		if (defined $alldata{$symbol}){
			$alldata{$symbol}{expr} = runavg( $alldata{$symbol}{count}, $alldata{$symbol}{expr}, \@d);
			$alldata{$symbol}{count}++;
			#print $allprobe{$d[0]},"\t";		
		} else {
			$alldata{$symbol}{expr} = [@d];
			$alldata{$symbol}{count}=1;
		}
	}
	#output
	# get rid of affy_probe column
	$header =~ s/\tprobe//;
	print $header;
	foreach my $k (sort keys %alldata){
		print "$k\t";
		#print "$alldata{$k}{count}\t";
		print join("\t", @{$alldata{$k}{expr}}),"\n";
	}
}

# average expression vals
# input: counts, ref to array of expr, ref to new array of expr
sub runavg{
	my ($count, $expr, $newexpr)=@_;
	die "divide by zero" if $count == 0;
	my @temp = ();
	for (my $i=0; $i< scalar @$expr; $i++){
		#print "$expr->[$i]\n";
		my $res = (($expr->[$i]*$count)+$newexpr->[$i])/($count+1);
		push @temp, $res;
	}
	#output_vector(\@temp);
	return (\@temp);
}


############ MAIN ##################
## average the replicate tissues
#average_inverted();

## average the replicate gene symbols
average_symbols();
