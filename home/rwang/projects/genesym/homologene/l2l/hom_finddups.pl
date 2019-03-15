#! /usr/bin/perl -w

######################################################
# hom_finddups.pl
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
# This program will identify duplicate gene entries in the 
# files created by hom_extract.pl
# Required input:
#	- human.hom, mouse.hom, rat.hom
#		these are created by hom_extract.pl from homolegene.data
#
# Output of this program is to the terminal. It will display the
# gene symbol and HomoloGeneID of any duplicate entries it finds.
# In order to decide which entry to delete, you may want to also 
# open the other .hom files, and see which HomoloGeneID that 
# symbol is associated with in the other species.
######################################################

@inputfiles = ("human.hom", "mouse.hom", "rat.hom");

foreach (@inputfiles) {
	open (INPUT, "$_");
	%allentries = ();
	print ("Processing $_\n");
	while (<INPUT>) {
		chomp;
		@row = split;
		if (exists $allentries{$row[1]}) {
			print ("\tGene $row[1], id $allentries{$row[1]} has a duplicate at id $row[0]\n");
		} else {
			$allentries{$row[1]} = $row[0];
		} # end if/else for testing duplicates
	} # end while INPUT
} # end foreach inputfiles