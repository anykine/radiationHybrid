#!/usr/bin/perl -w
#
# Count how many genes have a trans ceQTL marker within 1mb
# of it.
use strict;
use Data::Dumper;
use lib '/home/rwang/lib';
use t31markerpos;


my %mousegenes=(); # mouse gene locations

# all data is stored here, so output IN/OUT
sub output{
	foreach my $chr (sort { $a<=>$b} keys %mousegenes){
		for (my $i=0; $i < scalar @{$mousegenes{$chr}{start}}; $i++){
			print ${$mousegenes{$chr}{inout}}[$i], "\t";
			print ${$mousegenes{$chr}{symbol}}[$i], "\t";
			print ${$mousegenes{$chr}{start}}[$i], "\n";
		}
	}
	#print "number of keys is " , scalar (keys %mousegenes), "\n";

}

# 1. take the mouse marker positions and retain only
# 	those that are trans ceQTLs according to mouse trans peaks file
# 2. find which genes have a trans ceQTL marker < 1mb
sub filter_mouse_markers{
	open(INPUT, "trans_peaks_3.99.txt") || die "cannot open mouse trans peaks file\n";
	my %mousetrans = map {my @d = split(/\t/); $d[1] => 1;  } <INPUT>;
	load_markerpos_from_db("mouse_rhdb");
	load_markerpos_by_index("mouse_rhdb");
	# delete all mouse cgh markers that are not trans ceqtls
	foreach my $el (sort {$a<=>$b} keys %t31markerpos_by_index){
		if (defined $mousetrans{$el}){
			#print $el,"\n";
		} else {
			delete($t31markerpos_by_index{$el});	
		}
	}
	#print Dumper(\%t31markerpos_by_index);
	#foreach my $el (sort {$a<=>$b} keys %t31markerpos_by_index){
	#	print $el,"\n";
	#}
	
	#how trans ceqTLs are <1mb from a gene? (total 30,033 genes)
	foreach my $el (sort {$a<=>$b} keys %t31markerpos_by_index){
		my $chr = $t31markerpos_by_index{$el}{chrom};		
		my $mstart = $t31markerpos_by_index{$el}{start};		
		#iter over all genes on that chrom
		for( my $i=0; $i < scalar @{$mousegenes{$chr}{start}}; $i++){
			my $mgene = ${$mousegenes{$chr}{start}}[$i];
			#print "testing $mstart - $mgene = ", abs($mstart-$mgene),"\n";
			next if ${$mousegenes{$chr}{inout}}[$i] eq "IN";
			if (abs($mstart - $mgene) < 1000000){
				#stop, mark gene as within 1mb
				#print "IN $el $i\n";
				${$mousegenes{$chr}{inout}}[$i] = "IN";
				last;
			} else {
				#print "OUT $el $i\n";
				${$mousegenes{$chr}{inout}}[$i] = "OUT";
			}
		}
	}
}

# load up the ucsc mouse genes
sub load_ucsc_genes{
	open(INPUT, "ucsc_known_genes_chromosome_positions1.txt") || die "cannot open file";
	while(<INPUT>){
		next if /^#/; chomp;
		my ($sym, $chr, $start,$stop) = split(/\t/);
		push @{$mousegenes{$chr}{start}}, $start;
		push @{$mousegenes{$chr}{symbol}}, $sym;
		push @{$mousegenes{$chr}{inout}}, "NIL";
	}
	#foreach my $k (sort { $a<=>$b} keys %mousegenes){
	#	print "size of $k is ", scalar @{$mousegenes{$k}{start}}, "\n";
	#}
	#print "number of keys is " , scalar (keys %mousegenes), "\n";
}

######### MAIN #####################
# loads the mouse CGH markers by 
#print Dumper(\%t31markerpos);
load_ucsc_genes();
#print Dumper(\%mousegenes);
filter_mouse_markers();
#print Dumper(\%mousegenes);
output();
