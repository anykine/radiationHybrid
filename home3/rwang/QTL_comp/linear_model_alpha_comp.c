// Computes alpha model y=u+ax for experimental data set ...
// needs as input histogram_of_null_alphas.txt for p_value computation from
// linear_model_alpha_permute.c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

//library for fitting functions
#include <gsl/gsl_fit.h>

//total number of cell lines
#define CELLS	80 

// this typedef is a way to simplify 2D array creation
// it holds 99 doubles ... one row of data
typedef double RowArrayD[CELLS];

// upret is 2D array of upstream retention, will be same layout as input file
// downexp is for downstream expression
RowArrayD *upret, *downexp;

int uprows=235829;
int downrows= 20996;

// for histogram to store permuted ratios of SSRF/SSRN
int BINCNT = 100000000;

// File pointers for input and output
FILE *fi, *fo;

int main()
{
	// input files for upstream retention and downstream expression
	char upret_file[] = "g3cghnormalized.txt";
	char downexp_file[] = "final3_log10RHtoA23ratio.txt";
	
	// read in null distribution
	char input_hist[] = "/home/josh/Desktop/lod_calc/histogram_of_null_alphas.txt";

	// ouptut file
	char output_file[] = "alpha_model_results.txt";

	// initialized histogram for null distribution of p values 
	double *histogram_of_ratios;
	histogram_of_ratios = malloc (BINCNT * sizeof(double));

	// initialize memory for 2D arrays to hold input files
	upret = malloc(uprows * CELLS * sizeof(double));
	downexp = malloc(downrows * CELLS * sizeof(double));
	// ------------------------------------------------

	
	// some variables for reading in files-------------
	int row, col, gene, marker, i;
	char line[5000];
	char *pch;
	// -----------------------------------------------

printf ("Loading Input files ... \n");

	// read in histogram of null distribution
	fi = fopen(input_hist, "r");
	row=0;
	while(fgets(line, 15, fi) != NULL) 
	{
		histogram_of_ratios[row]=atof(line);
		row++;
	}
	fclose(fi);
	//---------------------------------------------------------------------

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
	
	// calculates sums of squares for expression data (null model)
	meanexp=sumexp/CELLS;
	r0=0;
	for ( i=0; i<CELLS; i++){
		r0=r0+pow((expr[i]-meanexp),2);
	}
	//------------------------------------------------


	// now that we have the downstream information ... iterate through all upstream data and compute model
	for (marker = 0; marker < uprows; marker++) {
		for (i=0; i<CELLS; i++) {
			// build array of cgh ratios for current upstream cgh marker
			cgh[i]=upret[marker][i];
		}

		// some variables for the fitting
		double mu, alpha, cov00, cov01, cov11, sumsq, pval;

		// gsl function for linear regression of y=u+ax model
		gsl_fit_linear(cgh, 1, expr, 1, CELLS, &mu, &alpha, &cov00, &cov01, &cov11, &sumsq);
	
		// lod score conversion ... directly copied from Sangtae's matlab code .. don't understand this 
		// lod = log10(exp(1))*99/2*log(r0/sumsq);

		// find p-value from null distribution
		int idx;
		idx = floor((sumsq/r0)*BINCNT); 
		pval = histogram_of_ratios[idx];
		
		// not done yet ... need to convert lod score to p-value
		// inefficient data output (lots!! of redundant gene marker information) will fix later?
		fprintf(fo, "%d\t%d\t%.4f\t%.4f\t%.4f\n", gene+1, marker+1, mu, alpha, -log10(pval));
	}	
}

printf("Done!\n");

// free up dynamically allocated memory 
fclose(fo);
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
