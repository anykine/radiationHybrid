#!/usr/bin/perl -w
#
# create plots of human cgh versus expression data for diagnositics
#

use strict;
use R;
use RReferences;

unless (@ARGV==2){
	print <<EOH;
	$0 <marker> <gene>
	create expr vs cgh plots
EOH
exit(1);
}

my $marker = $ARGV[0];
my $gene = $ARGV[1];

my @cgh=();
my @expr=();

# 235829 markers
open(CGH, '/home3/rwang/QTL_comp/g3cghnormalized.txt') || die "cannot open cgh\n";
while(<CGH>){
	chomp;
	push @cgh, $_; 
}
close(CGH);

# 20996 genes
open(EXPR, '/home3/rwang/QTL_comp/final3_log10RHtoA23ratio.txt') || die "cannot open expr\n";
while(<EXPR>){
	chomp;
	push @expr, $_;
}
close(EXPR);


#start R
&R::initR("--silent");
&R::library("RSPerl");

#plot only markers on this chrom
my @x = split(/\t/, $cgh[$marker-1]);
my @y = split(/\t/, $expr[$gene-1]);

#foreach (my $i=0; $i < scalar @x; $i++){
#	print "$x[$i]\t$y[$i]\n";
#	print "$x[$i]\n";
	#print "$y[$i]\n";
#}
#exit(1);

#plot data
my $title="peak marker/gene $marker/$gene ";
#&R::call("jpeg", 'plot'.$marker.'v'.$gene.'.jpg');
my $fname = 'plot'.$marker.'_'.$gene.'.jpg';
&R::callWithNames("jpeg", {'filename', $fname, 'width',800,'height',800}); 
#&R::call("plot", \@x, \@y); 
#&R::callWithNames("plot", {'x', \@x, 'y', \@y});
&R::callWithNames("plot", {'x', \@x, 'y', \@y, 'pch','*', 'xlab', 'cgh I', 'ylab','expr', 'main',$title});
&R::call("dev.off");



