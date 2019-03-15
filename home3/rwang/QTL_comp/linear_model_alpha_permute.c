// Computes null distribution of SSRF/SSRN for alpha model y=u+ax 
// outputs data to histogram_of_null_alphas.txt

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// library for fitting functions 
#include <gsl/gsl_fit.h>

// library for permutation functions
// Notation for seeding GSL _ random number generator
// GSL_RNG_TYPE="taus" GSL_RNG_SEED=123 ./a.out
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_permutation.h>

//total number of cell lines
#define CELLS 80 

// this typedef is a way to simplify 2D array creation
// it holds 80 doubles ... one row of data
typedef double RowArrayD[CELLS];

// upret is 2D array of upstream retention, will be same layout as input file
// downexp is for downstream expression
RowArrayD *upret, *downexp;

int uprows=235829;
int downrows= 20996;

// File pointers for input and output
FILE *fi, *fo;

// for histogram to store permuted ratios of SSRF/SSRN
int BINCNT=100000000;

int main()
{
	// input files for upstream retention and downstream expression
	char upret_file[] = "g3cghnormalized.txt";
	char downexp_file[] = "final3_log10RHtoA23ratio.txt";

	// ouptut file
	char output_file[] = "alpha_null_hist.txt";

	// some variables for reading in files-------------
	int row, col, gene, marker, i;
	char line[5000];
	char *pch;
	// -----------------------------------------------

	// initialize memory for 2D arrays to hold input files
	upret = malloc(uprows * CELLS * sizeof(double));
	downexp = malloc(downrows * CELLS * sizeof(double));
	// ------------------------------------------------

	// initialize histogram and set f@#$ thing to contain all zeros
	double *histogram_of_ratios;
	histogram_of_ratios = malloc (BINCNT *sizeof(double));
	for (i=0; i<BINCNT; i++){
		histogram_of_ratios[i]=0;
	}
	//--------------------------------------------------------------


printf ("Loading Input files ... \n");

	// read in Sangtae's scaled cgh data of upstream retention -------------
	fi= fopen(upret_file, "r");
	for (row = 0; row < uprows; row++)
	{
		fgets(line,5000,fi); 
		pch = strtok (line, "\t");
		col=0;
		while (pch != NULL) 
		{		
			upret[row][col]=atof(pch);
			pch = strtok (NULL, "\t\n");
			col++;
		}
	}
	fclose(fi);
	//------------------------------------------------


	// read in log10 downstream expression data-----------
	fi= fopen(downexp_file, "r");
	for (row = 0; row < downrows; row++)
	{
		fgets(line,5000,fi);
		pch = strtok (line, "\t");
		col=0;
		while (pch != NULL) 
		{									
			downexp[row][col]=atof(pch);
			pch = strtok (NULL, "\t\n");
			col++;
		}
	}
	fclose(fi);
	//------------------------------------------------




// open file for output
fo = fopen(output_file, "w");


// declare arrays of expression and upstream retention for input to regression
double expr[CELLS];
double cgh[CELLS];


// set up variables for permutation ------------------------------------------------------------------------
int k;
const size_t N = CELLS;
gsl_rng *r;
gsl_permutation *p = gsl_permutation_alloc (N); // remember to free it
gsl_rng_env_setup();
		
const gsl_rng_type *T;
T = gsl_rng_default;
r = gsl_rng_alloc(T);
	
gsl_permutation_init (p);
double dperm[CELLS];
//-----------------------------------------------------------------------------------------------------------

// Now the more interesting stuff
// here I loop through the first 10 genes and for each gene all 232626 rows of cgh data
// hack to run on both processors of dual processor computer is to create one c file that loops 
// from downrows to downrows/2 and one c file that loops from downrows/2 to downrows and run both simultaneously

printf("Beginning Computation ...\n");

for (gene = 0; gene < 10; gene++ ) { 
	
	double sumexp, meanexp, r0;
	sumexp=0;

	for (i=0; i<CELLS; i++ ) { 
		// build array of expression data for current downstream gene
		expr[i]=downexp[gene][i]; 
		// calculate sum of expression data 
		sumexp=sumexp+expr[i];
	}
	
	// calculates sums of squares for expression data (null model) .. not affected by permutations
	meanexp=sumexp/CELLS;
	r0=0;
	for ( i=0; i<CELLS; i++){
		r0=r0+pow((expr[i]-meanexp),2);
	}
	//------------------------------------------------


	// now that we have the downstream information ... iterate through all upstream data and compute model
	for (marker = 0; marker < uprows; marker++) {
		// 5 permutations per gene marker pair
		for (k=0; k<5; k++ ) {
			
			gsl_ran_shuffle (r, p->data, N, sizeof(size_t) );
			for (i=0; i< CELLS; i++){
				// now have array of permuted expression data
				dperm[i]=expr[gsl_permutation_get(p,i)];
			}
	
			for (i=0; i<CELLS; i++) {
				// build array of cgh ratios for current upstream cgh marker
				cgh[i]=upret[marker][i];
			}

			// some variables for the fitting
			double mu, alpha, cov00, cov01, cov11, sumsq, lod;

			// gsl function for linear regression of y=u+ax model
			gsl_fit_linear(cgh, 1, dperm, 1, CELLS, &mu, &alpha, &cov00, &cov01, &cov11, &sumsq);

			// populate histogram of null values
			int idx;
			idx = floor((sumsq/r0)*BINCNT); 
			histogram_of_ratios[idx]++;
		}	
	}
}

printf ("Processing Null Distribution Histogram ... \n");

// divide by total counts eventually 5*232626*20145 so that area under curve = 1
int j;
for (j=0; j<BINCNT; j++ ) {
	histogram_of_ratios[j]=histogram_of_ratios[j]/(5*uprows*10);
}

// turn into cummulative sum for p-val calculation
double cumsum;
cumsum=0;
for (j=1; j<BINCNT; j++ ) {
	cumsum=cumsum+histogram_of_ratios[j];
	histogram_of_ratios[j]=cumsum;
}

// output to file
for (j=0; j<BINCNT; j++ ) {
	fprintf(fo, "%e\n", histogram_of_ratios[j]);
}
fclose (fo);

printf("Done!\n");

//free up dynamically allocated memory
gsl_permutation_free(p);
free(histogram_of_ratios);
free(upret);
free(downexp);
};



/*
 //- Diagnostic for file read in -----------------------------	
 for (row=0; row< uprows; row++ ) {
 	for (col=0; col<CELLS; col++ ) {
		printf("%.3f\t",  upret[row][col]);
	}
 	printf("\n");
 }
//---------------------------------------------------------------
*/	
