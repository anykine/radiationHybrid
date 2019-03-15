#!/usr/bin/perl -w
#
# match files
# 1. find the TCGA CGH and EXPR matched files
# This code relies on expr and cgh files 
# being copied into directores like allcgh/ and allexprCEL/
#
# 2. merge samples data into one large file for regression
# for CGH: this uses normalized level2 data (probe, value) where
# value is the log2 ratio. 
# Output: a file of 200,000 rows and ~200 cols
use strict;
use File::Find;
use File::Copy;
use Data::Dumper;
use IO::File; # you gotta print wtih braces ie print { $fh[$file] }

# maps tcga to cel
# pass in hash to fill with data
# key: TCGA-02...  val:55000.G03.CEL
sub load_map{
	my ($hash) = @_;
	open(INPUT, "tmp/allsdrf.map") || die "cannot open tcga=>CEL file";
	while(<INPUT>){
		next if /^#/; chomp;
		my($barcode, $barfile) = split(/\t/);
		my @tmp = split(/level/, $barfile);
		#$$hash{ substr($barcode,0,19)} = $tmp[0]."CEL";
		$$hash{ substr($barcode,0,15)} = $tmp[0]."CEL";
	}
}

# check if CGH file exists by partial matching of file prefix
sub check_cgh{
	my $prefix = shift;
	#print "prefix = $prefix\n";
	#my @f = glob("/media/usbdisk/tcga/allcgh/$prefix*");
	my @f = glob("/media/usbdisk/tcga/cgh/level1/$prefix*");
	if ($#f == 0){
		#print "match** $f[0]\n\n";
		#return 1;
		return $f[0];
	} else {
		#print "no match \n\n";
		return 0;
	}
}

# check if EXPR CEL file exists by partial matching of file prefix
sub check_expr{
	my $prefix = shift;
	#print "exprprefix = $prefix\n";
	#my @f = glob("/media/usbdisk/tcga/allexprCEL/$prefix*");
	my @f = glob("/media/usbdisk/tcga/allexprCEL3/$prefix*");
	if ($#f == 0){
		#print "match** $f[0]\n\n";
		#return 1;
		return $f[0];
	} else {
		#print "no match \n\n";
		return 0;
	}
}

# find CEL files that have matching CGH and copy 
# to a new directory with name TCGA-02...
sub copy_matching{
	my %expr2file=();
	load_map(\%expr2file);
	foreach my $k (sort keys %expr2file){
		print $k,"\n";
		if (check_cgh($k) && check_expr($expr2file{$k})){
			#copy CEL file to allexprCEL2
			#print "allexprCEL/$expr2file{$k} \n";
			#print "allexprCEL2/$k \n";
	
			# from FILE module
			#copy("allexprCEL/$expr2file{$k}", "allexprCEL2/$k.CEL") || die "copy failed $!";
			copy("allexprCEL/$expr2file{$k}", "allexprCEL3/$k.CEL") || die "copy failed $!";
		}
	}
}

# merge sept files into one CGH/EXPR file
# as long as matching CGH&EXPR file exists
# either $cgh or $expr must be set to 1;
# Actually, EXPR was handled in R, so I only use this for CGH.
#  Used for level2 normalized CGH.
sub merge_matching{
	my ($params, $agilpos) = @_;
	if (!defined $params->{cgh} or !defined $params->{expr}) {
		die ("need to pass cgh or expr parameter");
	}
	my $i=0;
	my @fh=();	
	my %expr2file=();
	my @filepairs = ();
	load_map(\%expr2file);
	# add files to array of hashes
	foreach my $k (sort keys %expr2file){
		#if (check_cgh($k) && check_expr($expr2file{$k})){  #use this if CEL files NOT renamed TCGA
		if (check_cgh($k) && check_expr($k)){

			$filepairs[$i] = {
				cgh=>check_cgh($k),
				#expr=>check_expr($expr2file{$k}) #use this if CEL files are not renamed TCGA...
				expr=>check_expr($k)
			};
			#print $k,"has matched pair\n";
			#	print "\t",check_cgh($k), "\n";
			#	print "\t",check_expr($expr2file{$k}), "\n";
			$i++;
		}
	}
print_filepairs(\@filepairs);exit(1); #DEBUG
	# open all the files and store filehandles in array
	foreach my $k (@filepairs){
		if ($params->{cgh}==1){
			local *FILE;
			#print $k->{cgh},"\n";
			open(FILE, $k->{cgh}) or die "cannot open $k->{cgh}\n";
			#open my $fh, $k->{cgh} or die "cannot open $k->{cgh}\n";
			#push @fh, $fh;
			push(@fh, *FILE);
			#print $k->{cgh},"\n";
		} elsif ($params->{expr}==1){
			local *FILE;
			open(FILE, $k->{expr}) or die "cannot open $k->{expr}\n";
			push(@fh, *FILE);
		}
	}
	# now merge all files in to one file
	for (my $linenum=0; $linenum< 227614; $linenum++){
		# read one line from each file
		for (my $j=0; $j<= $#fh; $j++){
			#weird, but assign to handle, using the array[el] directly does not
			my $handle = $fh[$j];
			my ($probe,$val) = split(/\t/, <$handle>);
			chomp $val;
			#remove dos carriage return
			$val =~ s/\r//g;
			# skip the headers on cgh files
			if ($params->{cgh}==1){
				next if $linenum < 2;
			}
			if (defined ${$agilpos}{$probe}){
				# col1 print pos, last col newline, tab otherwise
				if ($j==0 ){
					print join("\t", $probe,
					${$agilpos}{$probe}->{chrom},
					${$agilpos}{$probe}->{start},
					${$agilpos}{$probe}->{stop},
					$val	), "\t";
				} elsif ($j==$#fh){
					print $val,"\n";
				} else {
					print $val,"\t";
				}
			}
		}
	}
	#print "$filepairs[0]{cgh} and $filepairs[0]{expr}","\n";
	#print Dumper(\@filepairs);
}
sub print_filepairs{
	my ($filepairs) = @_;
	my $count = 1;
	foreach my $k (@$filepairs){
		print $count,"\t$k->{cgh}\n";
		print $count++,"\t$k->{expr}\n";
	}
	exit(1);
}

#
# add position information to CGH file
# $agilpos is a hashref
#my %agilpos=(); #store positions
#my @agilprobelist=(); #store list of probes in order of file
sub load_cghpos{
	my ($agilpos) = @_;
	open(INPUT, "index/agilcgh/common_cgh1.txt") || die "cannot open pos";
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

###### MAIN ########################
#my $dir = './expr';
#find(\&wanted, $dir);
#sub wanted{
#	print "found it $File::Find::dir: $_ \n";
#}

#copy CEL files to new dir and rename
#copy_matching();

my %agilpos=();
load_cghpos(\%agilpos);
#print Dumper(\%agilpos);

merge_matching({cgh=>1,expr=>0}, \%agilpos);

