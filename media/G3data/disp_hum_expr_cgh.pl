#!/usr/bin/perl -w
#
# create plots of human cgh versus expression data for diagnositics
#

use strict;
use R;
#use RReferences;

my @cgh=();
my @expr=();

# 235829 markers
sub load_human_markers{
	open(CGH, '/home3/rwang/QTL_comp/g3cghnormalized.txt') || die "cannot open cgh\n";
	while(<CGH>){
		chomp;
		push @cgh, $_; 
	}
	close(CGH);
}

# 20996 genes
sub load_human_genes{
	open(EXPR, '/home3/rwang/QTL_comp/final3_log10RHtoA23ratio.txt') || die "cannot open expr\n";
	while(<EXPR>){
		chomp;
		push @expr, $_;
	}
	close(EXPR);
}


sub create_plot {
	my ($marker, $gene) = @_;

	#plot only markers on this chrom
	my @x = split(/\t/, $cgh[$marker-1]);
	my @y = split(/\t/, $expr[$gene-1]);

	#start R
	&R::initR("--silent");
	&R::library("RSPerl");
	
	#plot data
	my $title="expr-cgh marker/gene $marker/$gene ";
	#&R::call("jpeg", 'plot'.$marker.'v'.$gene.'.jpg');
	my $fname = 'plot_expr_cgh'.$marker.'_'.$gene.'.jpg';
	&R::callWithNames("jpeg", {'filename', $fname, 'width',800,'height',800}); 
	#&R::call("plot", \@x, \@y); 
	#&R::callWithNames("plot", {'x', \@x, 'y', \@y});
	&R::callWithNames("plot", {'x', \@x, 'y', \@y, 'pch','*', 'xlab', 'cgh I', 'ylab','expr', 'main',$title});
	&R::call("dev.off");
}

sub create_plot_pdf {
	my ($marker, $gene) = @_;

	#plot only markers on this chrom
	my @x = split(/\t/, $cgh[$marker-1]);
	my @y = split(/\t/, $expr[$gene-1]);

	#start R
	&R::initR("--silent");
	&R::library("RSPerl");
	
	#plot data
	my $title="expr-cgh marker/gene $marker/$gene ";
	#&R::call("jpeg", 'plot'.$marker.'v'.$gene.'.jpg');
	my $fname = 'plot_expr_cgh'.$marker.'_'.$gene.'.pdf';
	&R::call("pdf", $fname); 
	#&R::call("plot", \@x, \@y); 
	#&R::callWithNames("plot", {'x', \@x, 'y', \@y});
	&R::callWithNames("plot", {'x', \@x, 'y', \@y, 'pch','*', 'xlab', 'cgh I', 'ylab','expr', 'main',$title});
	&R::call("dev.off");
}

# create a text file for using in R manually
# (needed to draw in regression line)
sub create_plot_txt {
	my ($marker, $gene) = @_;

	#plot only markers on this chrom
	my @x = split(/\t/, $cgh[$marker-1]);
	my @y = split(/\t/, $expr[$gene-1]);

	open(OUTPUT, ">plot_expr_cgh".$marker.'_'.$gene.'.txt');
	for (my $i = 0; $i < scalar @x; $i++){
		print OUTPUT join("\t", $x[$i], $y[$i]),"\n";
	}
	#plot data
	#my $title="expr-cgh marker/gene $marker/$gene ";
	
}

########### MAIN #################
unless (@ARGV==2){
	print <<EOH;
	$0 <marker> <gene>
	Create expr vs cgh plots for Human data with filename plot_expr_cgh<marker>_gene.jpg
EOH
exit(1);
}

my $marker = $ARGV[0];
my $gene = $ARGV[1];

load_human_markers();
load_human_genes();

#create_plot($marker, $gene);
#create_plot_pdf($marker, $gene);
create_plot_txt($marker, $gene);
