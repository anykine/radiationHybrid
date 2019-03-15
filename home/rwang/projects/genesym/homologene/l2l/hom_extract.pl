#! /usr/bin/perl -w

######################################################
# hom_extract.pl
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
# This program will extract Homologene ids and gene symbols
# for human, mouse and rat genes from the homologene database file 
# Required input:
#	- homologene.data
#		this is the current release of the homologene database 
#		from ftp.ncbi.nlm.nih.gov/pub/HomoloGene/current/homologene.data
#
# The output files are named "human.hom", "mouse.hom" and "rat.hom",
# and are in the format:
#	HomoloGeneID	GeneSymbol
#
# Several gene symbols have duplicate HomologeneIDs, which will confuse
# output from mammalhom.pl. Use hom_finddups.pl on the output files to 
# identify duplicates, then delete duplicate entries by hand
######################################################

open (HUMAN, ">>human.hom");
open (MOUSE, ">>mouse.hom");
open (RAT, ">>rat.hom");
open (INPUT, "homologene.data");
while (<INPUT>) {
	chomp;
	@row = split;
	if ($row[1] == 9606) {
	print HUMAN ("$row[0]\t$row[3]\n");
	} elsif ($row[1] == 10090) {
	print MOUSE ("$row[0]\t$row[3]\n");
	} elsif ($row[1] == 10116) {
	print RAT ("$row[0]\t$row[3]\n");
	}
}
