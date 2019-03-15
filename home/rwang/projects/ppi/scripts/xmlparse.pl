#!/usr/bin/perl -w

# script to read in DIP MIF data
# -makes a hash of proteinInteractors ids mapped to ids in 
# swissprot, pir, gi
# -makes a list of interactions using proteinInteractor ids
#	-uses genename from swissprot to make gene network 
use strict;
use XML::Twig;
use Data::Dumper;
use Getopt::Std;
#add getops functionality
#my %options=();

# parse SwissProt for PIR data
my $pirhashref = {};
# parse GenBank
my $gbhashref = readGB("../genbank/acc2gn1.dat");
# parse SwissProt
my $swphash = readSWP("../swissprot/uniprot_sprot_humanrodent.dat");

# store the interactor id => protdb mappings from DIP XML
my $dataref = {};

#the output: genetic interactions
my %output = ();

my $twig_handlers = {'proteinInteractor' => \&interactor_ext,
	'interaction' => \&interaction_ext };

my $twig = new XML::Twig(TwigRoots=>{interactorList =>1, 
		interactionList=>1}, TwigHandlers => $twig_handlers);

$twig->parsefile("../dip/Hsapi20060402.mif");
#print Dumper($pirhashref);

writeData(\%output);

######## subroutines #########

#interaction as stored in DIP
# contains pairs of identifiers ex G_1 G_2
sub interaction_ext{
	my($twig, $title) = @_;
	my $pptlist = $title->first_child('participantList');
	my @ppts = $pptlist->children;
	my @genes = ();
	
	# for this interaction, put all genes into an array
	foreach my $i (@ppts) {
		
		#$i->first_child('proteinInteractorRef')->print;
		#print $i->first_child('proteinInteractorRef')->att('ref'),"-";
		my $prot = $i->first_child('proteinInteractorRef')->att('ref');
		#lookup Swissprot id in xml hash
		if (exists $dataref->{$prot}->{'SWP'}) {
			my $swpid = $dataref->{$prot}->{'SWP'};
			print "\nswissprot\n";
			print "$dataref->{$prot}->{'SWP'}= ";
			#lookup gene symbol for swissprot id	
			if (exists $swphash->{$swpid}) {
				print "$swphash->{$swpid}->{'gene'} ";
				push @genes, $swphash->{$swpid}->{'gene'};
			}
		#lookup PIR id in xml hash
		} elsif (exists $dataref->{$prot}->{'PIR'}) {
			my $pirid = $dataref->{$prot}->{'PIR'};
			print "\nPIR\n";
			print "$dataref->{$prot}->{'PIR'}= ";
			if (exists $pirhashref->{$pirid}) {
				print "$pirhashref->{$pirid} ";
				push @genes, $pirhashref->{$pirid};
			}
		#lookup RefSeq id in xml hash
		} elsif (exists $dataref->{$prot}->{'RefSeq'}) {
			my $refseqid = $dataref->{$prot}->{'RefSeq'};
			print "\nRefseq\n";
			print "$dataref->{$prot}->{'RefSeq'}= ";
			if (exists $gbhashref->{$refseqid}) {
				print "$gbhashref->{$refseqid} ";
				push @genes, $gbhashref->{$refseqid};
			}
		}
	}
	
	#minimum 2 interactors
	if (@genes >=2) {
		my $tmp = pop @genes; #first value into array becomes key of hash
		if (exists $output{$tmp} ) {
			my $arraycontents = join(" ", $output{$tmp});
			foreach my $i (@genes){
				push @{$output{$tmp}}, $i unless $arraycontents =~ /$i/;
			}
		} else {
			push @{$output{$tmp}}, @genes;
		}
	}
	print "\n";
	
}

#data stored as hash of hashes
#keys are SWP, PIR, RefSeq, GI, DIP
sub interactor_ext{
	my %data = ();
	my($twig, $title) = @_;
	#get protInteractor Id
	#print $title->att('id'), "\n";
	my $pref = $title->first_child('xref')->first_child('primaryRef');
	#get DIP id
	#print $pref->att('db'), "\n";
	#print $pref->att('id'), "\n";
	$data{$pref->att('db')} = $pref->att('id');
	my @list = $pref->next_siblings('secondaryRef');
	for my $i (@list) {
		#get 2ndary ids [SWP PIR GI REF]
		$data{$i->att('db')} = $i->att('id');
		#print $i->att('db'), "\n";
		#print $i->att('id'), "\n";
	}
	#print Dumper(\%data);
	my $key = $title->att('id'); 
	addToHash($key, \%data);
}

#DIP interactor ID => PIR, SWP, GI, RefSeq hash
sub addToHash{
	my($key, $hashref) = @_;
	$dataref->{$key} = $hashref;
	#print Dumper($dataref);
}

#parse the SwissProt file id=>gene name
# and PIR=>gene name
sub readSWP{
	my($file) = shift;
	# build mapping of swiss prot id->gene name
	# input swissprot files
	# output prot ids -> gene names
	#		sample data: 
	# AC P38383; P12345; 
	# GN Name=Exo1; Synonyms=Kip1, Waf1;
	
	open(INPUT, $file) || die "cannot open file: $!";
	my $inRecord = 0;
	my %hoh = ();
	my @acc = ();
	my @gn = ();
	my @syn = ();
	my @pir = ();
	while(<INPUT>){
		chomp($_);
		if (/^ID/) {$inRecord=1;}	
		if ($inRecord==1){
			if (/^AC/) {
				s/AC   //g;
				s/\s+//g;
				@acc = split(";");
				#print "@acc\n";
			}
			if (/^GN/) {
				s/GN   //g;
				@gn = split(";");
				#get the name
				if ($gn[0] =~ /Name=/){
					$gn[0] =~ s/Name=//;
					#print "name=$gn[0]\n";
				}
				#if synonym, get those
				if ($gn[1] =~ /Synonyms=/){
					$gn[1] =~ s/\s*Synonyms=//;
					$gn[1] =~ s/ //;
					#print "syns_all=$gn[1]\n";
					@syn = split(/,/, $gn[1]);
				}
			}
			if (/^DR/) {
				if (/PIR/){
					s/DR   PIR;//g;
					s/\s+//g;
					my @pirs = split(/;/);
					push(@pir, @pirs);
				}
			}
			if (/^\/\//) {
				$inRecord = 0;
				#assemble datastruct
				#for every prot id
				for my $i (@acc){
					$hoh{$i} = { 'gene'=>$gn[0],
											 'syn' => [@syn]
											};
				}
				#write PIR->gene name mapping
				for my $pir (@pir){
					$pirhashref->{$pir} = $gn[0];
				}
				#clear out vars
				$#acc = -1;
				$#gn = -1;
				$#pir = -1;
			}#inRecord
		}
	}#while
	close(INPUT);
	#print Dumper(\%hoh);
	return(\%hoh);
}

#read in genbank for refseq
# format is geneid, prot_accession, protein_gi, symbol
sub readGB{
	my($file) = shift;
	my %gbhash = ();
	open(INPUT, $file) || die "cannot open file: $!";
	while(<INPUT>){
	chomp($_);
	my @data = split(/\t/);
		$gbhash{$data[1]} = $data[3];
	}
	close(INPUT);
	#print "gbhash\n";
	#while ( my($k, $v) = each(%gbhash) ) {
	#	print "$k = $v\n";
	#}
	return(\%gbhash);
}

sub writeData{
        my($table) = @_;
        print "--output--\n";
        foreach my $i (keys %$table){
                print "$i: @{$table->{$i}}\n";
        }
        #print Dumper($table);
}
