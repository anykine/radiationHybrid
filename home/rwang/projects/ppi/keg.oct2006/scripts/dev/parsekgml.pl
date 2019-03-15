#!/usr/bin/perl -w
# 
# Takes KEGG pathway XML and extracts the nodes and edges
# and gets gene names
#
#
#
#


use strict;
use SOAP::Lite;
use Data::Dumper;
use XML::Twig;

############################3
# GLOBALS
#
############################3
my $file;
#my $file = $ARGV[0];
#my $file = "../xml/hsa04350.xml";
#my $file = "./test3.xml";
my %microarraygenes = ();
my %subtypes = ();    #relation subtypes
my $entryref = {};    #entries w/keggid & containers
my $DEBUG=1;

#SOAP stuff
my $wsdl= 'http://soap.genome.jp/KEGG.wsdl';
my $serv = SOAP::Lite->service($wsdl);

#twig stuff
my $twig_handlers = {'entry' => \&entry_handler,
	'relation' => \&relation_handler};
my $twig = new XML::Twig(TwigRoots=>{'pathway' => 1}, 
							TwigHandlers => $twig_handlers);

#run
load_kegg_subtypes();
load_microarray_reference();

#if i provide an input file, do that else, do it all
#if ($file){
#	$twig->parsefile($file);
#} else {
	chdir "/home/rwang/projects/ppi/kegg/xml/" || die "cannot open dir\n";
	while($file=<*.xml>){
		open(OUTPUT, ">./output/$file".".out")or die "cannot open file for output\n";
		print $file,"\n";
		$twig->parsefile($file);
		close(OUTPUT);
	}
#}
#debug
#print Dumper($entryref);

##################################
# Subroutines
##################################
sub entry_handler{
	my($t, $tag) = @_;
	print "id# =", $tag->att('id'),"\n";
	my $els=[];	
	#these entries are containers
	if ($tag->att('type') eq 'group') {
		my @children = $tag->children('component');
		foreach my $i(@children){
			push @{$els}, $i->att('id') ;
		}
		$entryref->{$tag->att('id')}->{els} = $els;
	#these entries ok
	} elsif (($tag->att('type') eq 'gene') && !(defined $tag->att('map'))) {
		$entryref->{$tag->att('id')} = {
			keggids=> [ split(/ /, $tag->att('name')) ],
			xcoord => $tag->first_child('graphics')->att('x')
		};
	# these entries are NOT entry or relation type
	} else {
		print "strange entry!\n" if $DEBUG;
		print $tag->att('type'),"\n" if $DEBUG;
	}
}
sub relation_handler{
	my($t, $tag) = @_;
	my @entries = ();
	my $reltypes;
	if (defined $tag->att('entry1') && defined $tag->att('entry2')){
		#lookup in entryids	list
		if ((exists $entryref->{$tag->att('entry1')} ) && 
			(exists $entryref->{$tag->att('entry2')})) {
			print "entry1=",$tag->att('entry1') ," entry2=", $tag->att('entry2'), "\n";
			push @entries, $tag->att('entry1'), $tag->att('entry2');
			#pass the relation pair in an array
			my $arrayref = assemble(@entries);
			#output the data along with type of relation
			my @reltypes = $tag->children('subtype');
			#more than one relation subtype
			if ($#reltypes > 0){
				my @types = ();
				foreach my $k (@reltypes){
					my $type = $k->att('name');
					$type=~s/\//_/;
					$type=~s/\s/_/;
					if (exists $subtypes{$type}) {
						push @types, $subtypes{$type};
					} else {
						push @types, 0;
					}
				}
				$reltypes = join("|",@types);
			} else {
				my $type = $reltypes[0]->att('name');
				$type=~s/\//_/;
				$type=~s/\s/_/;
				if (exists $subtypes{$type}) {
					$reltypes = $subtypes{$type};
				} else {
					$reltypes = 0;
				}
			}
			#this is an array with 2 els, each an array
			#loop throught the outer and inner arrays
			for (my $i=0; $i<=$#{$arrayref->[0]}; $i++){
				for (my $j=0; $j<=$#{$arrayref->[1]}; $j++){
					print OUTPUT "$arrayref->[0][$i]\t$arrayref->[1][$j]\t$reltypes\n";
				}
			}
		} else {
			#probably map elements, so ignore
			print "hash ref does not contain both entries!\n" if $DEBUG;
		}
	} else {
		print "relation contains bad specification!\n" if $DEBUG;
	}
}

#entries shoudl come in pairs
sub assemble{
	my(@entries) = @_;	
	my $ids;
	my @gset1=(); #holds AoA:1st A is 1st entry, 2nd A is 2nd entry
	#print "entries are @entries\n";
	#this should only go from 1->2 ie pair of entries
	for (my $i = 0; $i<=$#entries; $i++){
	#foreach my $i(@entries){
		#det if el1,el2 is an entry or container
		#this is a container
		if (exists $entryref->{$entries[$i]}->{els}) {
			#print "this is a container\n";
			foreach my $j(@{$entryref->{$entries[$i]}->{els}}) {
				#print "j=$j\n";
				$ids = $ids." ".join(" ", @{$entryref->{$j}->{keggids}});	
			}	
			#print "entrycomponents $ids\n";
			my $res = lookup($ids);
			@{$gset1[$i]} = parselookup($res);
		#this is an entry
		} elsif (exists $entryref->{$entries[$i]}->{keggids}) {
			#print "this is an entry\n";
			my $handle = $entryref->{$entries[$i]}->{keggids};
			my $ids = join(" ",@{$handle});
			#print "entryids=$ids\n";
			my $res = lookup($ids);
			#this gives me back the genes of this entry
			@{$gset1[$i]} = parselookup($res);
			#my @set1 = parselookup($res);
			#print Dumper(\@set1);
			#print "hi=$res";
		} else {
			print "does not exist!\n" if $DEBUG;
		}
	}#for
	#do magic to hookup genes and generate output
	# OR i can return to relation_handler
	#print Dumper(\@gset1);
	return \@gset1;
}
# uses DBGET interface to grab info
sub lookup{
	my($id) = shift;
	my $res = $serv->bget($id);
	return $res;
}
# parse DBGET file for name of genes, possibly multiple
# returns array of genes
sub parselookup{
	my($string) = shift;
	my @kegggenes=();
	#print "in lookup parse\n";
	#if ($string =~ /NAME/) {print "true\n"};
	while($string=~m/NAME\s+?(.+?)\n/g) {
		# here we need to check if gene name matches unigene
		my $value = $1;
		$value =~ s/\s//g;
		#crossreference with unigene names on uarray
		my @genelist = split(/,/, $value) if ($value=~/,/);
		foreach my $i(@genelist){
			my $key = uc $i;
			# if gene matches that in unigene, use it
			$value = $key if exists $microarraygenes{$key}; 
		}
		#if could not find a match in unigene hash, just pick one
		if ($value=~/,/) {
			my @genelist = split(/,/, $value);
			$value = $genelist[$#genelist];
		}
		push @kegggenes, $value;
		#print "match=", $value, "\n";
	}
	return @kegggenes;
}
#contains the reference gene names on microarray
sub load_microarray_reference{
	open(DB, "../../../G4121A_unigenenames.txt") or die "cannot open microarray genes!\n";
	while(<INPUT>){
		#uppercase the key
		my $key = uc $_;
		if (defined $microarraygenes{$key}){
			$microarraygenes{$key}++;
		} else {
			$microarraygenes{$key}=1;
		}
	}
	print "done loading microarray info\n";
}

sub load_kegg_subtypes{
	$subtypes{activation} = 1;	
	$subtypes{inhibition} = 2;	
	$subtypes{expression} = 3;	
	$subtypes{repression} = 4;	
	$subtypes{indirect_effect} = 5;	
	$subtypes{state_change} = 6;	
	$subtypes{binding_association} = 7;	
	$subtypes{dissociation} = 8;	
	$subtypes{phosphorylation} = 9;	
	$subtypes{dephosphorylation} = 10;	
	$subtypes{glycosylation} = 11;	
	$subtypes{ubiquitination} = 12;	
	$subtypes{methylation} = 13;	
	$subtypes{indirect} = 14;	
	$subtypes{complex} = 15;	
}
