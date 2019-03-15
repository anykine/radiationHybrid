#! /usr/bin/perl -w

######################################################
# m2h.pl
# Copyright (C) 2005  John C. Newman
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA
#
# http://www.fsf.org/licenses/gpl.txt
#
######################################################
# This is a modified version of mammalhom.pl designed for rapid
# conversion of mouse names to human names
# Required files:
#	- human.hom, mouse.hom
#		these are created by hom_extract.pl from homolegene.data
#	- input file (any name)
#		this must contain a list of mouse gene symbols
#
# The first argument is the input file, and the second argument 
# is the output file name. The program will always convert mouse -> human, 
# and inserts a blank line if no match. 
#
# Sample usage:
#	./m2h.pl inputfile outputfile
#
# The blank line is intended to help copy-and-paste the results 
# into a spreadsheet. The order of the gene symbols is preserved, 
# so the after pasting the list of genes into the input file, the 
# user can paste the list of genes from the output file back into 
# the spreadsheet next to the original list, and see at a glance 
# which genes matches could not be found for. Genes with no match 
# can be matched by hand in EntrezGene.
#
# The program can be used in single-gene mode by using the "-g" flag.
# Now the only argument passed is a single gene name, which is converted to
# its human match. 
#
# Sample usage:
#	./m2h.pl -g Cdkn1A
#
# The -i flag inverts the input and output species. In other words, "-i" lets you
# convert a human gene name to a mouse one, instead of vice versa. -i works with either
# the default batch mode, or single-gene mode.
#
# Sample usage:
#	./m2h.pl -ig CDKN1A
#
# m2h.pl is case-insensitive. All names are converted to upper-case
# before matching. This means the output is upper-case by default. HUGO names 
# are (almost) all upper-case, anyway, but the usual mouse format is for
# only the first letter to be uppercase. Therefore, mammalhom.pl will upper-case
# the first letter of the output name, is the user is converting TO mouse. This
# may result in some incorrect casing, since the first-letter-uppercase rule is not
# absolute, but it should generally produce correctly-formatted mouse gene names.
######################################################

use Getopt::Std;
use vars qw/$opt_g $opt_i/;
getopts('ig');

# if -i, invert the FROM and TO species
if ($opt_i) {
	$convertfrom = "human";
	$convertto = "mouse";
} else {
	$convertfrom = "mouse";
	$convertto = "human";
}
$ifnomatch = "yes";

# load the relevent name files into memory
open (FROM, "$convertfrom.hom") or die "Can't open file $convertfrom.hom";
open (TO, "$convertto.hom") or die "Can't open file $convertto.hom";
while (<FROM>) {
    chomp;
    @row = split;
    unless (exists $from_hash{$row[1]}) {
    	$row[1] = uc ($row[1]);
    	$from_hash{$row[1]} = $row[0];
    } # end unless
} # end while
close FROM;

while (<TO>) {
    chomp;
    @row = split;
    unless (exists $to_hash{$row[0]}) {
        $to_hash{$row[0]} = uc ($row[1]);
    }
} # end while
close TO;

# if the user uses -g, only check the gene passed as the argument
if ($opt_g) {
	$input = $ARGV[0];
	$genein = uc ($input);
	if (exists $from_hash{$genein}) {
        $genein_id = $from_hash{$genein};
        $geneout = $to_hash{$genein_id};
        # upper-case the first letter in the output name if converting to mouse
        if ($convertto eq "mouse") {
        	$geneout = lc($geneout);
        	$geneout = ucfirst($geneout);
        }
        print STDOUT ("$convertfrom $input maps to $convertto $geneout\n");
    } else {
        print STDOUT ("Can't convert $convertfrom $input\n");
    } # end if
} else {
# otherwise, process input and output files
	# get the input and output files
	$inputpath = $ARGV[0];
	$outputfile = $ARGV[1];
	
	# open the user-supplied input file
	open (INPUT, $inputpath) or die "Can't open input file $inputpath";
	while (<INPUT>) {
	    chomp;
	    push (@inputnames, uc ($_));
	} # end while
	close INPUT;
	
	# open the output file
	open (OUTPUT, ">>$outputfile");
	foreach $genein (@inputnames) {
	    if (exists $from_hash{$genein}) {
	        $genein_id = $from_hash{$genein};
	        $geneout = $to_hash{$genein_id};
	        # upper-case the first letter in the output name if converting to mouse
	        if ($convertto eq "mouse") {
	        	$geneout = lc($geneout);
	        	$geneout = ucfirst($geneout);
	        }
	        print STDOUT ("$convertfrom $genein maps to $convertto $geneout\n");
	        print OUTPUT ("$geneout\n");
	    } else {
	        if ($ifnomatch eq "yes") {
	            print OUTPUT ("\n");
	        }
	        print STDOUT ("Can't convert $convertfrom $genein\n");
	    } # end if
	} # end foreach
	close OUTPUT;
} # end if/else for testing -g   
     
        
        
        
        
        
        
        