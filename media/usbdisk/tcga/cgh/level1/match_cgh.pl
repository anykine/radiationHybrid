#!/usr/bin/perl -w
#
# borrows from match_files.pl
# 1. determine if level_1 CGH matches our expression/cgh sets
# 2. create file for CGHnormaliter R normalization
#    format is: probe, chrom, start, stop, samp1.test, samp1.control, samp2.test, samp2.control
use strict;
use File::Basename;
use File::Find;
use File::Copy;
use Data::Dumper;
use IO::File;

# add position information to CGH file
# $agilpos is a hashref
sub load_cghpos{
	my ($agilpos) = @_;
	open(INPUT, "../../index/agilcgh/common_cgh1.txt") || die "cannot open pos";
	while(<INPUT>){
		next if /^#/; chomp;
		my ($index, $chrom, $start, $stop, $probe, $sym) = split(/\t/);
		next if $chrom !~ /\d/;
		${$agilpos}{$probe} = {
			chrom=> $chrom,
			start=> $start,
			stop=> $stop,
			index=>$index,
			sym=>$sym
		};
	}
}

# this uses a previously generated file (matched_files.txt) from matched_files.pl
# which gives pairs of CGH and EXPR files.
# #cghfiles is a hashref containing filename prefix
sub match_cgh{
	my $cghfiles = shift;
	my $matches=0;
	my $nomatches=0;
	#open(INPUT, "../../matched_files.txt") || die "cannot open file"; 
	open(INPUT, "../../matched_files.cghl1.1.txt") || die "cannot open file";
	while(<INPUT>){
		chomp;next if /^#/;
		if ($. % 2 == 0){
			my @d = split(/\t/);
			my($file, undef, undef )= fileparse($d[1]);

			my $res = $file;
			#my $res = TCGAparse_sample($file); #only if filename needs to be munged
			if ($res){
				push @$cghfiles, $res;
				$matches++;
			} else {
				$nomatches++;
			}
		}
	}
	#print "$matches matches and $nomatches mis-matches\n";
	#print Dumper($cghfiles);
}

# extact enough of the file name to find match
# useful for CGH level2 normalized; large suffix needs chopping
sub TCGAparse_sample{
	my $file = shift;
	$file =~ s/_lowess_normalized.tsv//g;
	$file = $file . ".txt";
	my @f = glob("/media/usbdisk/tcga/cgh/level1/$file");
	if ($#f ==0){
		return $f[0];
	} else {
		return 0;
	}
}

# create a file formatted for R.CGHcall
# ID | chrom|start|End|Samp1|Samp2|...
#  NOTE: lots of trouble caused by some incomplete level CGH files
#        that did not have the same number of rows. Make sure those
#        files are all the same length.
sub format_CGHcall{
	my ($agilpos, $cghfiles) = @_;
	my @fh=();
	my %cols=(); #store probename,red/green columns for each file

	foreach my $k (@$cghfiles){
		local *FILE;
		open(FILE, $k) || die "cannot open $k";
		push @fh, *FILE;
		#print $k,"\n";
	}

	find_datacolsCGHcall(\@fh, \%cols);

	# for each line of all files
	for (my $linenum=0; $linenum < 243440; $linenum++){
	#for (my $linenum=0; $linenum < 25; $linenum++){
		my $curprobe;
		# for each file
		for (my $j=0; $j<=$#fh; $j++){
			#weird but only works like this
			my $handle = $fh[$j];
			my @d = split(/\t/, <$handle>);
			
			#skip the header lines
			next if $linenum < 11;

			#make your life easier, get the right column for this file
			my $probe = $d[ $cols{$j}{ProbeName} ];
			my $logratio = $d[ $cols{$j}{LogRatio} ];

			#print STDERR "file $j, line $linenum probe $probe\n";
			#print STDERR "diag: $d[6]\n";
			next if $probe !~ /A_/ ;

			#print $probe,"\n";
			#write probe and position
			if (defined ${$agilpos}{$probe}){
				#print "defined\n";
				if ($j==0){
					print join("\t", $probe,
						${$agilpos}{$probe}->{chrom},
						${$agilpos}{$probe}->{start},
						${$agilpos}{$probe}->{stop},
						$logratio), "\t";
					$curprobe = $probe;
				} elsif ($j == $#fh){
					#write gProcessedSignal | rProcessedSignal
					#print join("\t", $d[22], $d[23] ), "\n";
					die "crap files have different probe order\n\n" if ($probe ne $curprobe);
					print join("\t", $logratio), "\n";
				} else {
					die "crap files have different probe order\n\n" if ($probe ne $curprobe);
					print join("\t", $logratio), "\t";
				}
			} else {
				#print "not defined\n";
			}
		}
	}	
}

# For R CGHcall, we need the LogRatio column from
# every TCGA CGH file
sub find_datacolsCGHcall{

	my ($fh, $cols) = @_;
	#skip these lines
	for (my $j=0; $j<= $#{$fh}; $j++){
		#weird but only works like this
		my $handle = ${$fh}[$j];
		<$handle> for 1..9;
	}
	# line 10 of these files contains col headers
	for (my $filenum=0; $filenum<= $#{$fh}; $filenum++){
		my $handle = ${$fh}[$filenum];
		my @d = split(/\t/, <$handle>);

		#for each col, find the impt cols
		for (my $i=0; $i <= $#d; $i++){
			if ($d[$i] eq 'ProbeName'){
				$cols->{$filenum}{ProbeName} = $i;
			} 
			if ($d[$i] eq 'LogRatio'){
				$cols->{$filenum}{LogRatio} = $i;
			} 
		}
	}
	#print Dumper($cols); exit(1);
}

# create a file formatted for R.CGHnormliter:
# ID | chrom|start|End|Case1.test|Case1.ref|Case2.test|Case2.ref
#  NOTE: lots of trouble caused by some incomplete level CGH files
#        that did not have the same number of rows. Make sure those
#        files are all the same length.
sub format_normaliter{
	my ($agilpos, $cghfiles) = @_;
	my @fh=();
	my %cols=(); #store probename,red/green columns for each file

	foreach my $k (@$cghfiles){
		local *FILE;
		open(FILE, $k) || die "cannot open $k";
		push @fh, *FILE;
		#print $k,"\n";
	}

	find_datacols(\@fh, \%cols);

	# for each line of all files
	for (my $linenum=0; $linenum < 243440; $linenum++){
	#for (my $linenum=0; $linenum < 25; $linenum++){
		my $curprobe;
		# for each file
		for (my $j=0; $j<=$#fh; $j++){
			#weird but only works like this
			my $handle = $fh[$j];
			my @d = split(/\t/, <$handle>);
			
			#skip the header lines
			next if $linenum < 11;

			#make your life easier, get the right column for this file
			my $probe = $d[ $cols{$j}{ProbeName} ];
			my $rSignal = $d[ $cols{$j}{rProcessedSignal} ];
			my $gSignal = $d[ $cols{$j}{gProcessedSignal} ];

			#print STDERR "file $j, line $linenum probe $probe\n";
			#print STDERR "diag: $d[6]\n";
			next if $probe !~ /A_/ ;

			#print $probe,"\n";
			#write probe and position
			if (defined ${$agilpos}{$probe}){
				#print "defined\n";
				if ($j==0){
					print join("\t", $probe,
						${$agilpos}{$probe}->{chrom},
						${$agilpos}{$probe}->{start},
						${$agilpos}{$probe}->{stop},
						$rSignal, $gSignal), "\t";
					$curprobe = $probe;
				} elsif ($j == $#fh){
					#write gProcessedSignal | rProcessedSignal
					#print join("\t", $d[22], $d[23] ), "\n";
					die "crap files have different probe order\n\n" if ($probe ne $curprobe);
					print join("\t", $rSignal, $gSignal ), "\n";
				} else {
					die "crap files have different probe order\n\n" if ($probe ne $curprobe);
					print join("\t", $rSignal, $gSignal), "\t";
				}
			} else {
				#print "not defined\n";
			}
		}
	}	
}

# For CGHnormaliter:
# CGH files have slightly different formats, so column assignments
# are not all the same. Use col headers to determine which col is:
# Probe, gProcessedSignal and rProcessedSignal.
# $fh and $cols are references to hashes
sub find_datacols{

	my ($fh, $cols) = @_;
	#skip these lines
	for (my $j=0; $j<= $#{$fh}; $j++){
		#weird but only works like this
		my $handle = ${$fh}[$j];
		<$handle> for 1..9;
	}
	# line 10 of these files contains col headers
	for (my $filenum=0; $filenum<= $#{$fh}; $filenum++){
		my $handle = ${$fh}[$filenum];
		my @d = split(/\t/, <$handle>);

		#for each col, find the impt cols
		for (my $i=0; $i <= $#d; $i++){
			if ($d[$i] eq 'ProbeName'){
				$cols->{$filenum}{ProbeName} = $i;
			} 
			if ($d[$i] eq 'gProcessedSignal'){
				$cols->{$filenum}{gProcessedSignal} = $i;
			} 
			if ($d[$i] eq 'rProcessedSignal'){
				$cols->{$filenum}{rProcessedSignal} = $i;
			}
		}
	}
	#print Dumper($cols); exit(1);
}

######### MAIN #####################
#position of agilent probes 
my %agilpos=();   
my @cghfiles = (); #array of level1 cgh files
load_cghpos(\%agilpos);
match_cgh(\@cghfiles);
#print "@cghfiles";
#test: pop @cghfiles for 1..230;
# creates a file for CGHnormaliter, but lots of trouble there
#format_normaliter(\%agilpos,\@cghfiles );
format_CGHcall(\%agilpos,\@cghfiles );
