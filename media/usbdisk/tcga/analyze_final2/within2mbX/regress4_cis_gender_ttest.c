// To run, you may need to EXPORT LD_LIBRARY_PATH=/usr/local/lib
// before running.
// Computes alpha model y=u+ax for experimental data set ...
// needs as input histogram_of_null_alphas.txt for p_value computation from
// linear_model_alpha_permute.c
//
// This code has been changed to search do regression on one cis marker per gene.
// The input file of input cgh marker for each gene drives the program. (Previously
// we iterated all genes and all markers.)
// 
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
#define ALL 
//total number of cell lines
//#define CELLS 237	
#if defined FEMALE
#define CELLS 85	
#elif defined ALL
#define CELLS 237
#else
#define CELLS 152 
#endif

#define LINEBUFFER 10000

// this typedef is a way to simplify 2D array creation
// it holds 99 doubles ... one row of data
typedef double RowArrayD[CELLS];

// upret is 2D array of upstream retention, will be same layout as input file
// downexp is for downstream expression
RowArrayD *upret, *downexp;

int cghmarkers=88464;
//int exprgenes= 11209;  //tcga level1 data
int exprgenes= 11209;   //self normalized data


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
	char cghfile[] = "../tcga_cghfemale_sm.sc.filtX";
	char expr_file[] = "../tcga_exprfemale";
	// ouptut file
	char output_file[] = "regress_results1_female.txt";
	fprintf(stderr, "processing FEMALE\n");
#elif defined ALL
	char cghfile[] = "../tcga_cgh_sm.sc.filtX";
	char expr_file[] = "../tcga_expr.txt";
	char output_file[] = "regress_results1_all.txt";
	fprintf(stderr, "processing ALL\n");
#else
	char cghfile[] = "../tcga_cghmale_sm.sc.filtX";
	char expr_file[] = "../tcga_exprmale";
	// ouptut file
	char output_file[] = "regress_results1_male.txt";
	fprintf(stderr, "processing MALE\n");
#endif
	// initialize memory for 2D arrays to hold input files
	upret = malloc(cghmarkers * CELLS * sizeof(double));
	downexp = malloc(exprgenes * CELLS * sizeof(double));
	
	// some variables for reading in files-------------
	int row, col, gene, marker, i;
	char line[LINEBUFFER];
	char *pch;
	

fprintf(stderr,"loading cgh\n");
	// read in cgh data of upstream retention 
	fi= fopen(cghfile, "r");
	if (fi==NULL){
		fprintf(stderr,"cannot read in cgh file\n");
		exit(1);
	}

	for (row = 0; row < cghmarkers; row++) {
		fgets(line,LINEBUFFER,fi); 
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
		fgets(line,LINEBUFFER,fi);
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
	// This file specifies the gene number in the gene array and the 
	// cgh marker number: counter is just the number of lines in the file, including the header
	// 	cismarkers[counter][1] = gene number
	// 	cismarkers[counter][2] = cgh marker number
	// If size of file is large, set ulimit really high. Really should rewrite using malloc.
	int cismarkersfile=1506682;
	int cismarkers[cismarkersfile][2];
	fi = fopen("cis_2mb.txt", "r");
	if (fi==NULL){
		fprintf(stderr, "cannot read in cis markers within genes file\n");
		exit(1);
	}
	// skip the first line which contains header information:
	fgets(line, LINEBUFFER, fi);
	int test1, test2;
	for (row=0; row<(cismarkersfile-1); row++){
		fscanf(fi, "%d %d",  &cismarkers[row][0], &cismarkers[row][1]);	
		cismarkers[row][0] = cismarkers[row][0]-1;
		cismarkers[row][1] = cismarkers[row][1]-1;
		//printf("%d\t%d\n", cismarkers[row][0], cismarkers[row][1]);
	}
// open file for output
fo = fopen(output_file, "w");

// declare arrays of expression and upstream retention for input to regression
double expr[CELLS];
double cgh[CELLS];



fprintf(stderr,"Beginning Computation ...\n");

// outer loop
for (row = 0; row< cismarkersfile-1; row++){

	
	// build array of expression data for current downstream gene
	for (i=0; i<CELLS; i++ ) { 
		expr[i]=downexp[ cismarkers[row][0] ][i]; 
	}
	
	for (i=0; i<CELLS; i++) {
		cgh[i] = upret[ cismarkers[row][1]][i];
	}

	// some variables for the fitting
	double mu, alpha, cov00, cov01, cov11, sumsq, pval, r, t, tpval;

	// gsl function for linear regression of y=u+ax model
	gsl_fit_linear(cgh, 1, expr, 1, CELLS, &mu, &alpha, &cov00, &cov01, &cov11, &sumsq);
	
	r = gsl_stats_correlation(cgh, 1, expr, 1, CELLS);
	pval = corr_pvalue(r, CELLS-2);
	// Test if slope of alpha is signif different than zero
	// by t-test. Only output significant slopes
	t = alpha/sqrt(cov11);
	if (t>0)
		tpval = gsl_cdf_tdist_Q(t, CELLS-2);
	else
		tpval = gsl_cdf_tdist_P(t, CELLS-2);
	tpval *= 2;
	if (tpval < 0.05)
		fprintf(fo, "%d\t%d\t%.4f\t%.4f\t%.4f\t%.4f\n", cismarkers[row][0]+1, cismarkers[row][1]+1, mu, alpha, r, -log10(pval));
		//fprintf(fo, "stderr = %.4f  t=%.4f tpval=%.4f\n", sqrt(cov11), t, tpval);
	
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
