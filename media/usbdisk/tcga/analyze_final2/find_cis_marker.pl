#!/usr/bin/perl -w
use strict;
use Data::Dumper;

# For the TCGA, we find markers contained within each gene.
# Use this as input for the regression.

our %genelist=();
our %cgh=();

sub load_gene{
	# HAPMAP gene expr pos
	open(INPUT, "allexpr.txt") || die "error open norm expr";
	# skip first line
	<INPUT>;
	my $index= 1;
	while(<INPUT>){
		chomp;
		#my @d = split(/\t/);
		my($symbol, $chrom, $start, $stop) = split(/\t/);
		next if $chrom == 24;
		$genelist{$index++}= {
				chrom => $chrom,
				start => $start,
				stop => $stop,
				symbol => $symbol
		};
	}
}

sub load_cgh{
	#open(INPUT, "allcgh1.txt_smoothed.scaled.filt") || die "error cgh";
	#open(INPUT, "allcgh1.txt_smoothed.scaled.filt") || die "error cgh";
	open(INPUT, "allcgh1.txt_smoothed.scaled.filtX") || die "error cgh";
	<INPUT>;
	my $index = 1;
	while(<INPUT>){
		chomp;
		my($probe, $chrom, $start, $stop) = split(/\t/);
		push @{$cgh{$chrom}{index}}, $index++;
		push @{$cgh{$chrom}{start}}, $start;
		push @{$cgh{$chrom}{stop}}, $stop;
		push @{$cgh{$chrom}{symbol}}, $probe;
	}
}

sub find_cis_markers_to_gene{
	my $numgenes = keys(%genelist)."\n";
	#print $numgenes;
	my $radius = 2000000;
	#my $radius = 81000;

	print "#gene\tmarker\n";
	# iter over all genes, start at 1
	for (my $i=1; $i<=$numgenes; $i++){
		my @cis=();
		my($gchrom, $gstart, $gstop) = ($genelist{$i}{chrom}, $genelist{$i}{start}, $genelist{$i}{stop});
		#search over markers on the same chrom
		#print join("\t", $gchrom, $gstart, $gstop),"\n";
		for (my $m=0; $m < scalar @{$cgh{$gchrom}{start}}; $m++){
			
			#find cis begin/end marker
			if ( abs($gstart - ${$cgh{$gchrom}{start}}[$m]) < $radius) {
				#push @cis, $m;
				push @cis, ${cgh{$gchrom}{index}}[$m];
			} elsif ( abs($gstop - ${$cgh{$gchrom}{stop}}[$m]) < $radius) {
				#push @cis, $m;
				push @cis, ${cgh{$gchrom}{index}}[$m];
			}
		}
		@cis = sort {$a<=>$b} @cis;
		# print gene | start marker | stop marker
		if (@cis){
			#print "$i\t".$cis[0] . "\t" . $cis[$#cis] ."\n";
			#output as paired list (gene1, marker1; gene2,marker2; )
			 for my $el (@cis){
			 	print join("\t", $i, $el),"\n";
			 }
		}
	}
}

# do i need this? delete?
sub find_cis_markers_internal_to_gene{
	my $numgenes = keys(%genelist)."\n";
	#print $numgenes;
	my $radius = 2000000;
	#my $radius = 81000;
	# iter over all genes
	for (my $i=1; $i<=$numgenes; $i++){
		my @cis=();
		my($gchrom, $gstart, $gstop) = ($genelist{$i}{chrom}, $genelist{$i}{start}, $genelist{$i}{stop});
		#search over markers on the same chrom
		for (my $m=0; $m < scalar @{$cgh{$gchrom}{start}}; $m++){
			#find cis begin/end marker
			if ( (${$cgh{$gchrom}{start}}[$m] - $gstart > 0) && ( $gstop - ${$cgh{$gchrom}{stop}}[$m] > 0)) {
				#push @cis, $m;
				push @cis, ${cgh{$gchrom}{index}}[$m];
			} 
		}
		@cis = sort {$a<=>$b} @cis;
		# print gene | start marker | stop marker
		if ($#cis > 0){
			print "$i\t".$cis[0] . "\t" . $cis[$#cis] ."\n";
		}
	}
}

# find which cgh markers are located within a genic region
# What to do with overlapping genes?
sub find_cis_internal_to_gene{
	my ($cghref, $geneproberef) = @_;

	for (my $i=1; $i< scalar (keys %$geneproberef); $i++){
		my ($gchrom,$gsym) = ($geneproberef->{$i}{chrom},
			#$geneproberef->{$i}{genestart},
			#$geneproberef->{$i}{genestop},
			$geneproberef->{$i}{symbol});
		my $gstart = (defined $geneproberef->{$i}{genestart}) ? $geneproberef->{$i}{genestart} : $geneproberef->{$i}{start};
		my $gstop= (defined $geneproberef->{$i}{genestop}) ? $geneproberef->{$i}{genestop} : $geneproberef->{$i}{stop};

		#print join("\t", $gchrom, $gstart, $gstop, $gsym),"\n";
		#next;
		
		for (my $j=0; $j < scalar @{$cghref->{$gchrom}{start}}; $j++){
			if ($cghref->{$gchrom}{start}[$j] >= $gstart && $cghref->{$gchrom}{stop}[$j] <= $gstop){
				#print gene.idx | gene.start|gene.end|cgh.start|cgh.end|cgh.index
				print join("\t", $i, $gchrom, $gstart, $gstop, $gsym, 
						$cghref->{$gchrom}{symbol}[$j],
						$cghref->{$gchrom}{start}[$j],
						$cghref->{$gchrom}{stop}[$j],
						$cghref->{$gchrom}{index}[$j]),"\n";
			}
		}
	}
}

############# MAIN ###################
load_gene();
load_cgh();
#print scalar @{$cgh{24}{start}}; 
#print Dumper(\%genelist);exit(1);
#print Dumper(\%cgh);exit(1);
find_cis_markers_to_gene();
#find_cis_markers_internal_to_gene();
#find_cis_internal_to_gene(\%cgh, \%genelist);

