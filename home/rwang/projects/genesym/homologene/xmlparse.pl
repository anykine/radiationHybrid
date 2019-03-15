#!/usr/bin/perl -w

use strict;
use XML::Twig;
use Data::Dumper;
use Getopt::Std;

unless (@ARGV == 1){
	print <<EOH;
	usage $0 <homologene xml>

	Extracts corresponding Homologene gene symbols for mouse-human
EOH
exit(1);
}
#add getops functionality
#my %options=();

my $twig_handlers = {'HG-Entry' => \&hgentry_parse };
my $twig = new XML::Twig(TwigHandlers => $twig_handlers);

my %t= (test => 'HG-Entry_hg-id',
						'entry' => 'HG-Entry_genes',
						'gene' => 'HG-Gene',
						'taxid' => 'HG-Gene_taxid',
						'symbol'=>'HG-Gene_symbol',
						'aliases'=>'HG-Gene_aliases',
						'alias'=>'HG-Gene_aliases_E'
						 );
my %taxonomy = (human=> '9606', mouse =>'10090');
my %homology = ();
$twig->parsefile($ARGV[0]);
######## subroutines #########

sub hgentry_parse{
	my($twig,$el) = @_;
	my @humlist = ();
	my @mouselist = ();
	#must contain human and mouse 
	#collection of genes in homology
	my @list = $el->first_child($t{'entry'})->children($t{'gene'});
	#print "size of list " , scalar @list, "\n";
	foreach my $i (@list){
		if (defined $i->first_child($t{'taxid'})) {
			if ($i->first_child($t{taxid})->text eq $taxonomy{human}) {
				#get the gene_symbol
				if (defined $i->first_child($t{symbol})){
					push @humlist, $i->first_child($t{symbol})->text if $i->first_child($t{symbol})->text !~ /\Qjoin(' ', @humlist)\E/ig; 
				}
				#get the alias
				if (defined $i->first_child($t{aliases})) {
					my @alias = $i->first_child($t{aliases})->children($t{alias});
					foreach my $j (@alias){
						push @humlist, $j->text if $j->text !~ /\Qjoin(' ', @humlist)\E/ig;	
					}
				}
			}

			if	($i->first_child($t{taxid})->text eq $taxonomy{mouse}) { 
				if (defined $i->first_child($t{symbol})){
					push @mouselist, $i->first_child($t{symbol})->text if $i->first_child($t{symbol})->text !~ /\Qjoin(' ', @mouselist)\E/ig;
				}
				if (defined $i->first_child($t{aliases})) {
					my @alias = $i->first_child($t{aliases})->children($t{alias});
					foreach my $j (@alias){
						push @mouselist, $j->text if $j->text !~ /\Qjoin(' ', @mouselist)\E/ig;	
					}
				}
			}
			#print $i->first_child('HG-Gene_symbol')->text if defined $i->first_child('HG-Gene_symbol');
			
		}# if taxid
	}#foreach
	
	#if both mouse and human, generate cross join
	if (@humlist && @mouselist) {
		crossjoin(\@humlist, \@mouselist);
	}
	#print "humanlist @humlist\n";
	#print "mouselist @mouselist\n";
	$twig->purge;
}

sub crossjoin{
	my($humlistref, $muslistref) = @_;
	foreach my $i (@$humlistref){
		foreach my $j (@$muslistref) {
			print "$i\t$j\n";
		}
	}
}
