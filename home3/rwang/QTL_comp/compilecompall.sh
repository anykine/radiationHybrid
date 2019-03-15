#!/bin/bash
gcc josh_debug_permute.c -o jdp -lgsl -lgslcblas -lm -D_FILE_OFFSET_BITS=64
