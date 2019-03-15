#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;
use POSIX qw(ceil floor);

#human chrom http://feb2006.archive.ensembl.org/Homo_sapiens/mapview?chr=1
#ensembl feb 2006 (ncbi 35)
# 23 = chrX; 24=chrY;
my %chromlength=(
				1=>245522847,
				2=>243018229,
				3=>199505740,
				4=>191411218,
				5=>180857866,
				6=>170975699,
				7=>158628139,
				8=>146274826,
				9=>138429268,
				10=>135413628,
				11=>134452384,
				12=>132449811,
				13=>114142980,
				14=>106368585,
				15=>100338915,
				16=>88827254,
				17=>78774742,
				18=>76117153,
				19=>63811651,
				20=>62435964,
				21=>46944323,
				22=>49554710,
				23=>154824264,
				24=>57701691
);

my %genepos = ();
my %markerpos = ();

print "step1\n";
buildMarkerHash();
print "step2\n";
buildGeneHash();
print "step3\n";
split_cistrans();

#splitting on a window of 5MB
sub split_cistrans{
	open(INPUT, 'g3alpha_model_results_gt4.txt') || die "cannot open results\n";
	open(CISOUT, '>g3alpha_model_results1_gt4cis.txt') || die "cannot open cis for write\n";
	open(TRANSOUT, '>g3alpha_model_results1_gt4trans.txt') || die "cannot open trans for write\n";
	while(<INPUT>){
		chomp;
		my @line = split(/\t/);  #gene, marker, mu, alpha, pval)
		if ( abs( $genepos{$line[0]} - $markerpos{$line[1]}) > 5000000 ){
			print TRANSOUT join("\t", @line),"\n";
		} else {
			print CISOUT join("\t", @line),"\n";
		}
	}
	close(CISOUT);
	close(TRANSOUT);
	close(INPUT);

}

sub buildGeneHash{
	open(INPUT, '/home3/rwang/expr/phase2/ilmn_goodpos.txt') || die "cannot open gene pos\n";
	my $counter=1;
	while(<INPUT>){
		next if /^#/;
		chomp;
		my(undef, $chr,$start,$stop) = split(/\t/);
		$genepos{$counter} = makegc($chr,$start,$stop);
		$counter++;
	}
}

sub buildMarkerHash{
	# load cgh markerpos
	open(INPUT, '/home3/rwang/cgh/final_cgh/g3matrix_pos_sorted_nodup_smoothed_posonly') || die "cannot open cgh pos\n";
	my $counter=1;
	while(<INPUT>){
		chomp;
		my($chr,$start,$stop) = split(/\t/);
		$chr =~ s/chr//;
		$chr =~ s/^0//;
		$start =~ s/^0*//ig;
		$stop  =~ s/^0*//ig;
		#print "$chr $start $stop ", makegc($chr, $start, $stop), "\n";
		$markerpos{$counter} = 	makegc($chr,$start,$stop);
		$counter++;
	}
}
#-------------------------
# Make genome coords
# ------------------------
sub makegc{
	my($chr,$start,$stop) = @_;	
	my $chromSum=0;
	$chr = 23 if $chr eq 'X';
	$chr = 24 if $chr eq 'Y';
	if (1==$chr) {
		return floor(($start+$stop)/2);
	} else{
		for (my $i=1; $i < $chr; $i++){
			$chromSum += $chromlength{$i};
		}
		return floor(($start+$stop)/2) + $chromSum;
	}
}
		

