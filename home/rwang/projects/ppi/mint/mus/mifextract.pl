#!/usr/bin/perl -w
# 7/25/06
#
# this routine extracts protein interactions from the MINT
# database. It gets the gene names involved in interactions
#
use strict;
use XML::Simple;
use Data::Dumper;
use constant DEBUGGING => 0;

### BEGIN ###
my($xml, $data, $intactionRef, $intactorRef, $InteractorIndex);
my %interactionTable = ();

#force interactions node into array
$xml = new XML::Simple(KeyAttr=>"content", ForceArray=>[qr/^interaction$/, qr/^interactor$/]);

#directory of files to read
my $directory = "./test";
opendir(DIR, $directory) or die $!;
while(my $file = readdir(DIR)) {
	next unless ($file =~ m/\.xml$/);

	$data = $xml->XMLin($file);
	print "filename = $file\n" ;
	#print Dumper($data)";
	$intactionRef = $data->{entry}->{interactionList}->{interaction};
	$intactorRef = $data->{entry}->{interactorList}->{interactor};
	
	#build interaction index table
	$InteractorIndex = makeInteractorIndex($data);
	
	#list of protein interactions
	#look at each interaction
	foreach my $key1 (@$intactionRef) {
		print "interactionID=$key1->{id}","\n" if DEBUGGING;
		#print $key1->{participantList}->{participant}->[0]->{interactorRef};
		#get the participants of the interaction
		my $parray= $key1->{participantList}->{participant};
		my @participants = ();
		foreach my $participant (@$parray) {
				#get reference to interactor
				my $ref= $participant->{interactorRef};
				print "intactorRef=", $ref, "\n" if DEBUGGING;
				push @participants, $ref;
				#now look at interactors to get gene name
		}
		getInteraction(\@participants, $InteractorIndex,\%interactionTable);
	}
}

closedir(DIR);
writeData(\%interactionTable);

# write out datastructure
sub writeData{
	my($table) = @_;
	print "--output--\n";
	foreach my $i (keys %$table){
		print "$i: @{$table->{$i}}\n";
	}
	#print Dumper($table);
}
### END ###


#search index for interactorID and get gene name
#inputs: arrayRef is a ref to the array of participants
#        index is a ref to id->gene hash
#        table is the interaction table for everything
sub getInteraction{
	my($arrayRef, $index, $tableRef) = @_;
	#sort the array of participants, first one is the hashkey
	sort(@$arrayRef);
	#assume first numerical participant is the main interactor
	my $hashkey = readIndex($index, $arrayRef->[0]);
	print "hashkey = $hashkey\n" if DEBUGGING;
	for (my $count=1; $count<=$#$arrayRef; $count++){
		my $t = readIndex($index, $arrayRef->[$count]);	
		#print "value=$t\n";

		#check if value is already in hash
		if (exists $tableRef->{$hashkey} ) {
			my $tmp = join(" ", @{$tableRef->{$hashkey}} );
			print "arraycontents=" , $tmp, "\n" if DEBUGGING;
			if ($tmp =~ /$t/) {
				print "$t is already present\n" if DEBUGGING;
			} else {
				push @{$tableRef->{$hashkey}},  $t; 
			}
		} else {
			push @{$tableRef->{$hashkey}},  $t; 
		}
		#my $arraycontents = join(" ", @{$tableRef->{$hashkey}});
		#push @{$tableRef->{$hashkey}},  $t if $arraycontents !~ /$t/;	
	}
	print Dumper($tableRef) if DEBUGGING;
}

# get the name of the gene from id->gene hash
# return without the ending*
sub readIndex{
	#if you don't use (), you assign the size of the array, not values
	my($index, $ref)=@_;
	foreach my $i (@{$index->{$ref}}) {
		#get starred* gene name
		if ($i=~/\*$/) {
			#make a copy and return it
			my $gn = $i;
			$gn =~s/\*$//;
			return $gn;
		}
		#return $i if $i=~/\*$/;
	}
}

# creates a global hash of id->gene name
# to be used by above routines; * is the official gene name
sub makeInteractorIndex{
	my($id,$gn);
	my($data) = @_;
	my %geneSyn = ();
	my $ppi = $data->{entry}->{interactorList}->{interactor};
	foreach my $i (@$ppi){
		$id = $i->{id};
		#print "$id\n";
		foreach my $hashkey (keys %{$i->{names}->{alias}}) { 
			if ($hashkey eq 'content') {
				#weird bug with XML::Simple when there is only one
				#alias for a gene, get data directly 
				$gn = $i->{names}->{alias}->{content};
				$gn .="*";
				#print "h=$gn\n";	
				push @{$geneSyn{$id}}, $gn;
			} elsif ($hashkey eq 'typeAc' || $hashkey eq 'type') {
				#weird bug with XML::Simple when there is only one
				#alias for a gene, ignore values 
			} else {
				#XML::Simple should have made each gene name into a hashkey
				#check if its the official gene name or synonym and star official one
				if ($i->{names}->{alias}->{$hashkey}->{type} eq 'gene name') {
					$hashkey .="*";	
				}
				#print "h=$hashkey\n";
				push @{$geneSyn{$id}}, $hashkey;
			} #if
		} #foreach
	}#foreach
	print Dumper(\%geneSyn) if DEBUGGING;
	return \%geneSyn;
}

