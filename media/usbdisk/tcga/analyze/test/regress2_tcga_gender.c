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
#define CELLS 85
#else
#define CELLS 152 
#endif
// this typedef is a way to simplify 2D array creation
// it holds 99 doubles ... one row of data
typedef double RowArrayD[CELLS];

// upret is 2D array of upstream retention, will be same layout as input file
// downexp is for downstream expression
RowArrayD *upret, *downexp;

int cghmarkers=227605;
int exprgenes= 11209;


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
double expr[CELLS];
double cgh[CELLS];
fprintf(stderr,"loading cgh\n");
	// read in cgh data of upstream retention 
	fi= fopen("male", "r");
	if (fi==NULL){
		fprintf(stderr,"cannot read in cgh file\n");
		exit(1);
	}

	int row=0;
	for (row = 0; row < 152; row++) {
		fscanf(fi, "%lf %lf", &expr[row], &cgh[row]);	
		printf("%lf\t%lf\n", expr[row], cgh[row]);
	}

		// some variables for the fitting
		double mu, alpha, cov00, cov01, cov11, sumsq, pval, r;

		// gsl function for linear regression of y=u+ax model
		gsl_fit_linear(cgh, 1, expr, 1, CELLS, &mu, &alpha, &cov00, &cov01, &cov11, &sumsq);
	
		r = gsl_stats_correlation(cgh, 1, expr, 1, CELLS);
		pval = corr_pvalue(r, CELLS-2);
		printf("%.4lf\t%.4lf\t%.4lf\t%.4lf\n", mu, alpha, r, -log10(pval));
	}	


