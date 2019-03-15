#!/bin/bash
gcc linear_model_alpha_comp.c -o alphacomp -lgsl -lgslcblas -lm -D_FILE_OFFSET_BITS=64
