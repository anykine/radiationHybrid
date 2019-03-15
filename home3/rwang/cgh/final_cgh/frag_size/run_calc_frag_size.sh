#!/usr/bin/sh
perl calculate_frag_size.pl 3000000 > fragsizes3mb.txt
perl calculate_frag_size.pl 500000 > fragsizes500kb.txt
perl calculate_frag_size.pl 250000 > fragsizes250kb.txt
perl calculate_frag_size.pl 100000 > fragsizes100kb.txt
