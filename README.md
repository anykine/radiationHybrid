This is a copy of the programs and scripts (C, perl, R) I developed while working
on my dissertation using radiation hybrid data to investigate copy number
effects on gene expression using Illumina microarrays.

Code is in drive2, home, home3, media

## lib

lib/ - perl modules for manipulating compact binary versions of CGH data


## QTL

Mapping of copy number eQTLs. I did this for multiple data sets
(human, rat, mouse, dog) and also compared with other data sets
such as GNF Novartis (symatlas) and TCGA data.


## rhvec

Co-retention of RH markers across different animal panels (human, rat, mouse dog)


### useful code

Possibly useful code bits

#### convert data to binary

Make binary version of CGH data matrix to allow for faster lookup. Perl modules
are used to access the data quickly.

#### linear model

C code for linear regression using GSL and permutation code to derive p value of alpha values.

#### correlation

I derived how to compute a correlation doing a single pass through the data.
Implemented in C.

#### chi square

C implementation of chi square computation

#### synteny plot

Create synteny plot in C using GD library

#### streak

for a 2d matrix (such as image) looks for islands to connected features.
In black and white image matrix, will count the number of (black) islands
using recursive algorithm 

streakupd/ - this version saves the data to file for really huge 2d matrices.
