#! /usr/bin/perl -w

######################################################
# mammalhom.pl
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
# This program will help the user convert gene symbols between
# mammalian species (human, mouse or rat)
# Required files:
#	- human.hom, mouse.hom, rat.hom
#		these are created by hom_extract.pl from homolegene.data
#	- input file (any name)
#		this must contain a list of gene symbols from one of the three species
#
# After launching the program, simply follow the prompts. The choice of 
# adding an empty line for failed matches is intended to help copy-and-paste
# the results into a spreadsheet. The order of the gene symbols is preserved, 
# so the after pasting the list of genes into the input file, the user can paste
# the list of genes from the output file back into the spreadsheet next to the
# original list, and see at a glance which genes matches could not be found for.
# Genes with no match can be matched by hand in EntrezGene.
#
# mammalhom.pl is case-insensitive. All names are converted to upper-case
# before matching. This means the output is upper-case by default. HUGO names 
# are (almost) all upper-case, anyway, but the usual mouse format is for
# only the first letter to be uppercase. Therefore, mammalhom.pl will upper-case
# the first letter of the output name, is the user is converting TO mouse. This
# may result in some incorrect casing, since the first-letter-uppercase rule is not
# absolute, but it should generally produce correctly-formatted mouse gene names.
######################################################

# prompt the user for input
print STDOUT ("Select the species you wish to convert from [(h)uman, (m)ouse, (r)at]:\n");
$convertfrom = <STDIN>;
chomp $convertfrom;
if ($convertfrom eq "h") { $convertfrom = "human"; } 
elsif ($convertfrom eq "m") { $convertfrom = "mouse"; } 
elsif ($convertfrom eq "r") { $convertfrom = "rat"; }
print STDOUT ("Select the species you wish to convert to [(h)uman, (m)ouse, (r)at]:\n");
$convertto = <STDIN>;
chomp $convertto;
if ($convertto eq "h") { $convertto = "human"; } 
elsif ($convertto eq "m") { $convertto = "mouse"; } 
elsif ($convertto eq "r") { $convertto = "rat"; }
print STDOUT ("Enter the path to the file you wish to convert:\n");
$inputpath = <STDIN>;
chomp $inputpath;
print STDOUT ("Name your output file:\n");
$outputfile = <STDIN>;
chomp $outputfile;
print STDOUT ("If I can't find a match, should I print an empty line in the output? [(y)es/no]:");
$ifnomatch = <STDIN>;
chomp $ifnomatch;
if ($ifnomatch eq "y") { $ifnomatch = "yes"; }

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

# open the user-supplied input file
open (INPUT, $inputpath) or die "Can't open input file $inputpath";
while (<INPUT>) {
    chomp;
    push (@inputnames, uc ($_));
} # end while
close INPUT;

# open the output file
open (OUTPUT, ">>$outputfile") or die "Can't open output file";
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
        
        
        
        
        
        
        
        