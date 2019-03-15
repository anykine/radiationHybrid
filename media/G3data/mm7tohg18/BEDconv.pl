#!/usr/bin/perl -w
#
use strict;
use Getopt::Long;

# options
#human or mouse
#BED or notBED format
#input filename
#
my $species = "";
my $bedflag = 0 ;
my $file= "";

sub checkOptions{
	my $options = GetOptions('species=s' => \$species,
					'BED' => \$bedflag,
					'file=s'=>\$file
					);
	
	if (!$options) {
		usage();
	}
	if ($species !~ /human|mouse/) {
		print "*invalid species\n";
		usage();
	}
	if (! -e $file ) {
		print "*invalid file\n";
		usage();
	}
}

sub usage {
	print <<EOH;
	Convert file to BED format or nonBED format. The difference is
	the appending of "chr" to the beginning of chroms and giving
	X=20|23 and Y=21|24 depending on species.

	usage $0 
		--species [human | mouse] : input file is human or mouse
		--bed : convert to BED (if blank will convert to nonBED) 
		--file <filename to read> : name of tile to process
EOH
exit(1);
}

sub convert{
	my($species, $bed, $file) = @_;
	open(INPUT, $file) || die "cannot open input file\n";
	while(<INPUT>){
		next if /^#/;
		# covert to BEd, append chr and change to X,Y
		if ($bed){
			s/^/chr/;
			if ($species eq 'human'){
				s/^chr23/chrX/;
				s/^chr24/chrY/;
			} else {
				#mouse
				s/^chr20/chrX/;
				s/^chr21/chrY/;
			}
		# convert to nonBED< strip chr and change to 23/24 (or 20/21)
		} else {
			s/^chr//i;
			if ($species eq 'human'){
				s/^X/23/;
				s/^Y/24/;
			} else {
				s/^X/20/;
				s/^Y/21/;
			}
		}
		print ;

	}
}
#-------------------------------------------
# MAIN
#
unless (@ARGV > 1){
	usage();
}
checkOptions();
convert($species, $bedflag, $file);
