// Computes alpha model y=u+ax for experimental data set ...
// needs as input histogram_of_null_alphas.txt for p_value computation from
// linear_model_alpha_permute.c
//
// This code specifically only looks at cis +/- 2MB from start/end of gene
// for faster computation.
// This is specific for gender
// CHANGE THE FOLLOWING:
//    CELLS
//    cgh_file
//    expr_file
//    output_file
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

//library for fitting functions, tdist
#include <gsl/gsl_fit.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_cdf.h>
#include <gsl/gsl_statistics.h>

// SEX SPECIFIC CODE
#define MALE
//total number of cell lines
//#define CELLS 237	
#if defined FEMALE
#define CELLS 86
#else
#define CELLS 154 
#endif

// this typedef is a way to simplify 2D array creation
// it holds 99 doubles ... one row of data
typedef double RowArrayD[CELLS];

// upret is 2D array of upstream retention, will be same layout as input file
// downexp is for downstream expression
RowArrayD *upret, *downexp;

int cghmarkers=227605;
//int exprgenes= 11209;  //tcga level1 data
int exprgenes= 10688;   //self normalized data


// File pointers for input and output
FILE *fi, *fo;

// ------------------------------------------------
// utility function to chomp off newlines
// ------------------------------------------------
int chomp(char* s){
	int chomped=0;
	char *p=strchr(s, '\n');
	if (p !=NULL){
		*p = '\0';
		chomped = 1;
	}
	return chomped;
}

// ------------------------------------------------
// get a pvalue for correlation, using GSL tdist
// ------------------------------------------------
double corr_pvalue(double pearson_corrcoef, double df){
	if (df < 0)
		err("degrees of freedom is unreadable");

	if (pearson_corrcoef > 1 || pearson_corrcoef < -1)
		err("correlation is out of bounds");

	//calculate the statistic S from this equation
	double s = 1.0 * pearson_corrcoef * sqrt(df)/(sqrt(1-pow(pearson_corrcoef, 2)));
	//printf("s is %lf df is %lf\n", s, df);

	//s follows a tdist, using a 1-sided cumulative dist
	// and only gives a one-sided test
	double pval = gsl_cdf_tdist_Q(s, df);

	// to get the 2-sided test, you need to multiply x2
	// but the quantile of s may be greater than 0.5, so
	// adjust accordingly
	
	if (pval <0.5){
		pval = 2.0*pval;
	} else {
		pval = 2.0*(1-pval);
	}
	//the pval could be divided by two if two-tailed test
	return pval;
}
// ------------------------------------------------
//  MAIN 
// ------------------------------------------------
int main(void) {
	
	// input files for upstream retention and downstream expression
#if defined FEMALE
	char cghfile[] = "cghfemale";
	char expr_file[] = "exprfemale";
	// ouptut file
	char output_file[] = "regress_results1_female.txt";
	fprintf(stderr, "processing FEMALE\n");
#else
	char cghfile[] = "cghmale";
	char expr_file[] = "exprmale";
	// ouptut file
	char output_file[] = "regress_results1_male.txt";
	fprintf(stderr, "processing MALE\n");
#endif
	// initialize memory for 2D arrays to hold input files
	upret = malloc(cghmarkers * CELLS * sizeof(double));
	downexp = malloc(exprgenes * CELLS * sizeof(double));
	
	// some variables for reading in files-------------
	int row, col, gene, marker, i;
	char line[5000];
	char *pch;
	

fprintf(stderr,"loading cgh\n");
	// read in cgh data of upstream retention 
	fi= fopen(cghfile, "r");
	if (fi==NULL){
		fprintf(stderr,"cannot read in cgh file\n");
		exit(1);
	}

	for (row = 0; row < cghmarkers; row++) {
		fgets(line,5000,fi); 
		pch = strtok (line, "\t");
		col=0;
		while (pch != NULL) {		
			upret[row][col]=atof(pch);
			pch = strtok (NULL, "\t\n");
			col++;
		}
	}
	fclose(fi);


fprintf(stderr,"loading expr\n");
	// read in log10 downstream expression data-----------
	fi= fopen(expr_file, "r");
	if (fi==NULL){
		fprintf(stderr,"cannot read in expression file\n");
		exit(1);
	}
	for (row = 0; row < exprgenes; row++) {
		fgets(line,5000,fi);
		pch = strtok (line, "\t");
		col=0;
		while (pch != NULL) {									
			downexp[row][col]=atof(pch);
			pch = strtok (NULL, "\t\n");
			col++;
		}
	}
	fclose(fi);
	//------------------------------------------------

fprintf(stderr,"loading markers per gene\n");
	// this file has cis markers for each gene (startmarker|stopmarker)
	int cismarkers[exprgenes][2];
	int junk;
	fi = fopen("cis_markers.txt", "r");
	if (fi==NULL){
		fprintf(stderr, "cannot read in cis markers\n");
		exit(1);
	}
	for (row=0; row<exprgenes; row++){
		fscanf(fi, "%d %d %d", &junk, &cismarkers[row][0], &cismarkers[row][1]);	
		cismarkers[row][0] = cismarkers[row][0]-1;
		cismarkers[row][1] = cismarkers[row][1]-1;
	}
// open file for output
fo = fopen(output_file, "w");

// declare arrays of expression and upstream retention for input to regression
double expr[CELLS];
double cgh[CELLS];


// Now the more interesting stuff
// here I loop through the first 10 genes and for each gene all 232626 rows of cgh data
// hack to run on both processors of dual processor computer is to create one c file that loops 
// from exprgenes to downrows/2 and one c file that loops from downrows/2 to downrows and run both simultaneously

fprintf(stderr,"Beginning Computation ...\n");

// outer loop
//for (gene = 0; gene < 1; gene++ ) { 
for (gene = 0; gene < exprgenes; gene++ ) { 
	
	// build array of expression data for current downstream gene
	for (i=0; i<CELLS; i++ ) { 
		expr[i]=downexp[gene][i]; 
	}
	

	// now that we have the downstream information ... iterate through all upstream data and compute model
	for (marker = cismarkers[gene][0]; marker <= cismarkers[gene][1]; marker++) {
	//for (marker = 0; marker < cghmarkers; marker++) {
		// build array of cgh ratios for current upstream cgh marker
		for (i=0; i<CELLS; i++) {
			cgh[i] = upret[marker][i];
		}

		// some variables for the fitting
		double mu, alpha, cov00, cov01, cov11, sumsq, pval, r;

		// gsl function for linear regression of y=u+ax model
		gsl_fit_linear(cgh, 1, expr, 1, CELLS, &mu, &alpha, &cov00, &cov01, &cov11, &sumsq);
	
		r = gsl_stats_correlation(cgh, 1, expr, 1, CELLS);
		pval = corr_pvalue(r, CELLS-2);
		//printf("%d\t%d\t%.4lf\t%.4lf\t%.4lf\t%.4lf\n", gene+1, marker+1, mu, alpha, r, -log10(pval));
		fprintf(fo, "%d\t%d\t%.4f\t%.4f\t%.4f\t%.4f\n", gene+1, marker+1, mu, alpha, r, -log10(pval));
	}	
	fprintf(stderr,"gene %d done\n", gene);	
}

fprintf(stderr,"Done!\n");

// free up dynamically allocated memory 
fclose(fo);
free(upret);
free(downexp);
};


/*
 //- Diagnostic for file read in -----------------------------	
 for (row=0; row< cghmarkers; row++ ) {
 	for (col=0; col<CELLS; col++ ) {
		printf("%.3f\t",  upret[row][col]);
	}
 	printf("\n");
 }
//---------------------------------------------------------------
*/	
