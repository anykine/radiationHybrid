#!/usr/bin/perl -w
#
# Extract data from binary file
#  and create plots of zero-gene eQTLs

# Uses the R.pm module, if it doesn't work try the bash file
# /usr/local/lib/R/site-library/RSPerl/scripts/RSPerl.bsh

#constants
use Fcntl ":seek";
use strict ;
use lib '/home/rwang/lib/';
use hummarkerpos;
use Data::Dumper;
use Getopt::Std;
use R;
#use RReferences;

my %options=();

my $headersize = 32;
my $recsize = 20;
my $num_genes=0;
my $num_markers=0;
my $buffer;
my $address=0;
#seek(INPUT, $address, SEEK_SET) or die "Seeking $!";
#read(INPUT, $buffer, 32);

# goto loc and get the header
sub read_header{
	my $buffer;
	#header is 32 bytes
	# - uint headersize
	# - char[8]
	# - uint num genes
	# - uint num markers
	# - u long int num entries (8bytes), but this doesn't work well, so i use 2 ints
	my $headerFORMAT = "I A8 I2 I2";
	#position at beg of file
	seek(INPUT, 0, SEEK_SET) or die "Seeking $!";
	read(INPUT, $buffer, $headersize);
	my @fields = unpack($headerFORMAT, $buffer);
	#dump
	#foreach my $i (@fields){ 
	#	print $i,"\n";
	#}
	$num_genes = $fields[2];
	$num_markers= $fields[3];
	
}

# obtain a gene-marker pair of data
sub get_record{
	my ($gene,$marker) = @_;
	# record is 20 bytes
	# -int gene id
	# -int marker id
	# -float mu
	# -float alpha
	# -float neg log pval
	my $recFORMAT = "I2 f3";
	#comute the linear address of marker-gene
	my $address = 32+$recsize*(($gene-1)*235829+$marker-1);
	seek(INPUT, $address, SEEK_SET) or die "Seeking $!";
	read(INPUT, $buffer, 20);
	my @fields = unpack($recFORMAT, $buffer);
	#foreach my $i (@fields){
	#	print $i,"\n";
	#}
	#print join("\t", @fields), "\n";
	return (@fields);
}

sub create_marker_chrom_plot{
		my ($gene, $marker) = @_;

		#print Dumper(\%hummarkerpos_by_index);exit(1);
		if (defined $hummarkerpos_by_index{$marker}{chrom} ){
			my $mchrom = $hummarkerpos_by_index{$marker}{chrom};
		#print "chrom=$mchrom\n";	
			#get starting index for this chrom
			my $mstartidx = ${$hummarkerpos{$mchrom}{idx}}[0];
			my $mendidx =  $mstartidx + $#{$hummarkerpos{$mchrom}{idx}};

			#R-perl plotting doesn't work correctly, write data to text file instead
			print "writing data to file...";
			open(OUTPUT, ">plotdata".$marker."v".$gene."chr".$mchrom.".txt") || die "cannot open output file";

		#print "$mstartidx to $mendidx\n";	
			#plot only markers on this chrom
			my @x=(); my @y=();
			for (my $i=$mstartidx; $i<=$mendidx; $i++){
				my @data = get_record($gene, $i);
				#geneid | markerid | mu | alpha | nlp
				#get the coordinates
				print OUTPUT $hummarkerpos_by_index{$data[1]}{pos},"\t",$data[4],"\n";
				#push @x, $hummarkerpos_by_index{$i}{pos}/1000000;
				push @x, ($hummarkerpos_by_index{$data[1]}{pos}/1000000);
				push @y, $data[4];
				
			}

			print "done!\n";
			#plot data
			# !Warning, xaxis seems off, plot manually...
			#my $title="peak marker/gene $marker/$gene, chrom=$mchrom";
			#&R::call("pdf", 'plot'.$marker.'v'.$gene.'chr'.$mchrom.'.pdf');
			#&R::callWithNames("plot", {'', \@x, '', \@y, 'pch','.', 'xlab', 'pos', 'ylab','', 'main',$title});
			#&R::call("dev.off");
		}
}

##### MAIN ##############

unless (@ARGV == 2){
	print <<EOH;
	usage $0 <gene number> <marker number>

	Plots the zero-gene peaks and surrounding markers on the same
	chrom as the peak. Useful for seeing if zero-gene peaks are
	outliers or supported by evidence.
	
EOH
exit(1);
}

open(INPUT, "g3alpha_model_results1.bin") || die "cannot open binary file\n";
read_header();
#get_record(1, 100);
my $genenum = $ARGV[0]; 
my $markernum =  $ARGV[1];

#import %hummarkerpos and %hummarkerpos_by_index
load_markerpos_from_db("g3data");
load_markerpos_by_index("g3data");

#start R
&R::initR("--silent");
&R::library("RSPerl");

create_marker_chrom_plot($genenum, $markernum);


# this was used to create zero gene plots (zgplots)
sub automate_zero_gene_plots{
	open(ZGP, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks_ucschg18.txt") || die "cannot open zero gene peaks file\n";
	my $c=0;
	while(<ZGP>){
		chomp;
		my($gene,$marker) = split(/\t/);
		#print "$gene and $marker\n";
		
		#get marker's chrom
		if (defined $hummarkerpos_by_index{$marker}{chrom} ){
			print STDERR 'working on '. $c++ . "\n";
			my $mchrom = $hummarkerpos_by_index{$marker}{chrom};
		#print "chrom=$mchrom\n";	
			#get starting index for this chrom
			my $mstartidx = ${$hummarkerpos{$mchrom}{idx}}[0];
			my $mendidx =  $mstartidx + $#{$hummarkerpos{$mchrom}{idx}};
		#print "$mstartidx to $mendidx\n";	
			#plot only markers on this chrom
			my @x=(); my @y=();
			for (my $i=$mstartidx; $i<=$mendidx; $i++){
				my @data = get_record($gene, $i);
				#geneid | markerid | mu | alpha | nlp
				#get the coordinates
				#print $hummarkerpos_by_index{$data[1]}{pos},"\t",$data[4],"\n";
				push @x, $hummarkerpos_by_index{$data[1]}{pos};
				push @y, $data[4];
				
			}
			#plot data
			my $title="peak marker/gene $marker/$gene, chrom=$mchrom";
			&R::call("pdf", 'zgplots/plot'.$marker.'v'.$gene.'chr'.$mchrom.'.pdf');
			&R::callWithNames("plot", {'', \@x, '', \@y, 'pch','*', 'xlab', 'pos', 'ylab','', 'main',$title});
			&R::call("dev.off");
		}
	}
}
