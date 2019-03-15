#!/bin/bash
gcc linear_model_alpha_permute.c -o alphaperm -lgsl -lgslcblas -lm -D_FILE_OFFSET_BITS=64
