// --------------------------------------------------
// Program: g3cispermute.
// Compiled as: cispermute 
// Based on: linear_model_alpha_permute.c (Josh Bloom)
// modified by RW 4/9/10 1AM...gawd
// Purpose: Computes null distribution of SSRF/SSRN for alpha model y=u+ax 
//          outputs data to histogram_of_null_alphas.txt
//          for cis markers to gene only
// --------------------------------------------------
//
// Need to initialize Random number generator on command line like this
// GSL_RNG_TYPE="taus" GSL_RNG_SEED=123 ./cispermute <arg1> <arg2> <arg3>

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
// CORRELATION USING DOUBLE is defined here! 
// default is to use int, which is usually not what you want!
#include <gsl/gsl_statistics_double.h>

//total number of cell lines for G3
#define CELLS 80 

// this typedef is a way to simplify 2D array creation
// it holds 99 doubles ... one row of data
typedef double RowArrayD[CELLS];

// upret is 2D array of upstream retention, will be same layout as input file
// downexp is for downstream expression
RowArrayD *upret, *downexp;

int uprows=235829;			//number of CGH probes
int downrows= 20996;	  //number of genes
int cghrows = 235829;
int exprrows = 20996;

// File pointers for input and output
FILE *fi, *fo, *fe;

// for histogram to store permuted ratios of SSRF/SSRN
int BINCNT=100000000;


//-----------------------------
//
// simple error handler
//
//-----------------------------
void err(char *s){
	printf("****%s\n", s);
	printf("****exiting\n");
	exit(1);
}

//-----------------------------
//
// LOAD CIS marker 
//
//-----------------------------

void load_cis( int** cismarkers){
	FILE* fp;
	int i=0, junk, v1,v2;
	int cis[20996][2];
	fp = fopen("cismarkers/g3cis5mb.txt", "r");
	if (fp==NULL)
		err("cannot open cis markers");
	while( fscanf(fp, "%d %d %d", &junk, &v1, &v2 ) != EOF){
	//while( fscanf(fp, "%d %d %d", &junk, cismarkers+i, *(cismarkers+i)+1 ) != EOF){
		cismarkers[i][0] = v1;
		cismarkers[i][1] = v2;
		//printf("%d %d\n", cismarkers[i][0], cismarkers[i][1]);
		//printf("%d %d\n", v1,v2);
		i++;
	}
	
}

//-----------------------------
//
// allocate INT space for EXPR/CGH 
//  data
//
// nrows: # rows in data matrix
// ncols: # cols in data matrix
//-----------------------------
int** allocate_intgrid(int nrows, int ncols){
	int** ptr;
	ptr = malloc(nrows * sizeof(int*));
	if (ptr==NULL)
		err("allocate grid fail 1");
	int i;
	for (i=0; i<nrows; i++){
		ptr[i]  = malloc(ncols * sizeof(int));
		if (ptr[i]==NULL)
			err("error in allocate");
	}
	return ptr;
}
//-----------------------------
//
// allocate space DOUBLE for EXPR/CGH // data
//
// nrows: # rows in data matrix
// ncols: # cols in data matrix
//-----------------------------
double** allocate_grid(int nrows, int ncols){
	//RowArrayD *ptr;	
	double** ptr;
	// each el is a pointer to double array, not double
	ptr = malloc(nrows * sizeof(double*));
	if (ptr==NULL)
		err("allocate grid fail 1");
	int i;
	for (i=0; i<nrows; i++){
		ptr[i]  = malloc(ncols * sizeof(double));
		if (ptr[i]==NULL)
			err("error in allocate");
	}
	/*ptr = malloc(rows * cols* sizeof(double));
	if (ptr==NULL)
		err("could not allocate memory");
	*/
	return ptr;
}

//-----------------------------
//
// LOAD expresion 
// 
//-----------------------------
void load_expr( double** array){
	FILE* fp;
	char buffer[5000];
	int row, col;
	char* pch;

	char exprfile[] = "/home3/rwang/QTL_comp/final3_log10RHtoA23ratio.txt";
	fp = fopen(exprfile, "r");
	if (fp==NULL)
		err("cannot open expr file");

	for (row = 0; row < exprrows; row++) {
		fgets(buffer,5000,fp);
		pch = strtok (buffer, "\t");
		col=0;
		while (pch != NULL) {									
			//printf("%lf\n", atof(pch));
			array[row][col]=atof(pch);
			pch = strtok (NULL, "\t\n");
			col++;
		}
	}
}

//-----------------------------
// Generic
// Load CGH/EXPR data into an array
// You MUST allocate_grid() first!
//
// nrows: # rows in file
// ncols: # cols in file (not used)
// file: file
//-----------------------------
void load_data(int nrows, int ncols, char* file, double** array){
	FILE* fp;
	char buffer[5000];
	int row, col;
	char* pch;

	fp = fopen(file, "r");
	if (fp==NULL)
		err("cannot open file load data file");

	for (row = 0; row < nrows; row++) {
		fgets(buffer,5000,fp);
		pch = strtok (buffer, "\t");
		col=0;
		while (pch != NULL) {									
			//printf("%lf\n", atof(pch));
			array[row][col]=atof(pch);
			pch = strtok (NULL, "\t\n");
			col++;
		}
	}
}
//-----------------------------
//
// debug the fileloader
//
//-----------------------------
void debug_load_expr(int nrows, int ncols, double **array){
	int i,j;
	for(i=0; i<nrows; i++){
		for (j=0; j<ncols; j++){
			if (j==(ncols-1)){
				printf("%lf\n", array[i][j]);
			} else {
				printf("%lf\t", array[i][j]);
			}
		}
	}
}

void print1Darray(int nsize, double* array){
	int i=0;
	for (i=0; i<nsize; i++){
		if (i==(nsize-1)){
			fprintf(stderr, "%lf\n", array[i]);
		} else {
			fprintf(stderr, "%lf\t", array[i]);
		}
	}
}

//-----------------------------
//
// Permute
// 
// nsize = # of cells (ie 80)
// npermutations = # times to permute
//
// output: writes histogram file
//-----------------------------
void permute(int nsize, int npermutations, double** cgh, double** expr, int** cismarkers){

	int i,k, gene, marker;
	// GSL permutation setup
	gsl_rng *RNG;
	gsl_permutation *PERM = gsl_permutation_alloc (nsize); // remember to free it
	gsl_rng_env_setup();
	const gsl_rng_type *T;
	T = gsl_rng_default;
	RNG = gsl_rng_alloc(T);
	gsl_permutation_init (PERM);

	double *histogram_of_ratios;
	histogram_of_ratios = malloc (BINCNT *sizeof(double));
	for (i=0; i<BINCNT; i++){
		histogram_of_ratios[i]=0;
	}

	//permutation steps
	for (gene = 0; gene < 20996; gene++ ) { 
		fprintf(stderr, "%i\n", gene);
		double *permarray = malloc(nsize * sizeof(double));
		if (permarray==NULL)
			err("failure to allocate permarray");
	
		double sumexp, meanexp, r0;
		sumexp=0;
		// sum of squares for expression
		for (i=0; i<nsize; i++ ) { 
			sumexp=sumexp+expr[gene][i];
		}
		
		// calculates sums of squares for expression data (null model) .. not affected by permutations
		meanexp=sumexp/nsize;
		r0=0;
		// residuals for null model y=mu
		for ( i=0; i<nsize; i++){
			r0=r0+pow((expr[gene][i]-meanexp),2);
		}
		
		for (marker = cismarkers[gene][0]; marker < cismarkers[gene][1]; marker++) {
			if (marker%100==0)
				fprintf(stderr, "\tmarker %d\n", marker);
			// N permutations per gene marker pair
			for (k=0; k<npermutations; k++ ) {
				gsl_ran_shuffle (RNG, PERM->data, nsize, sizeof(size_t) );
				for (i=0; i< nsize; i++){
					// now we have array of permuted expression data
					/*fprintf(stderr, "%d\t", gsl_permutation_get(PERM,i));
					if (i==(nsize-1))
						fprintf(stderr, "\n");*/
					permarray[i]=expr[gene][gsl_permutation_get(PERM,i)];
				}
			
				// some variables for the fitting
				double mu, alpha, cov00, cov01, cov11, sumsq, lod;
	
				// gsl function for linear regression of y=u+ax model
				gsl_fit_linear(cgh[marker], 1, permarray, 1, nsize, &mu, &alpha, &cov00, &cov01, &cov11, &sumsq);
	//fprintf(stderr, "%lf %lf\n", sumsq, r0);
				// populate histogram of null values
				int idx;
	
				if (r0 == 0.0) {
					printf("error: divide by zero\n");
					printf("error: idx=%d\tgne=%d\tmarker=%d\titer=%d\n", idx, gene, marker, k);
				} else {
					// our modified F-statistic: sumsq/r0 is always < 1, scaled by #bins in hist
					idx = floor((sumsq/r0)*BINCNT);
				}
				if (idx > BINCNT-1) {
					idx = BINCNT - 1;
				}
				histogram_of_ratios[idx]++;
			}	//permutations
		} //markers
	}//gene

	int j;
	fo = fopen("cis_null_distrib.txt", "w");
	for (j=0; j<BINCNT; j++ ) {
		//output partN of histogram to file, merge later
		fprintf(fo, "%f\n", histogram_of_ratios[j]);
	}
} //end main

//-----------------------------
//
// Do the regression on cis 
// 
//-----------------------------
void cis_regress(int nsize, double** cgh, double** expr, int** cismarkers){
	int i,k, gene, marker;
	double *histogram_of_ratios;

	//store histograms for cis alpha
	histogram_of_ratios = malloc (BINCNT *sizeof(double));
	for (i=0; i<BINCNT; i++){
		histogram_of_ratios[i]=0;
	}

	for (gene = 0; gene < 20996; gene++ ) { 
		fprintf(stderr, "%i\n", gene);
	
		double sumexp, meanexp, r0;
		sumexp=0;
		// sum of squares for expression
		for (i=0; i<nsize; i++ ) { 
			sumexp=sumexp+expr[gene][i];
		}
		
		// calculates sums of squares for expression data (null model) .. not affected by permutations
		meanexp=sumexp/nsize;
		r0=0;
		// residuals for null model y=mu
		for ( i=0; i<nsize; i++){
			r0=r0+pow((expr[gene][i]-meanexp),2);
		}
		
		for (marker = cismarkers[gene][0]; marker < cismarkers[gene][1]; marker++) {
			
			// some variables for the fitting
			double mu, alpha, cov00, cov01, cov11, sumsq, lod;
	
			// gsl function for linear regression of y=u+ax model
			gsl_fit_linear(cgh[marker], 1,  expr[gene], 1, nsize, &mu, &alpha, &cov00, &cov01, &cov11, &sumsq);
	
			// populate histogram of null values
			int idx;
	
			if (r0 == 0.0) {
				printf("error: divide by zero\n");
				printf("error: idx=%d\tgne=%d\tmarker=%d\titer=%d\n", idx, gene, marker, k);
			} else {
				// our modified F-statistic: sumsq/r0 is always < 1, scaled by #bins in hist
				idx = floor((sumsq/r0)*BINCNT);
			}
			if (idx > BINCNT-1) {
				idx = BINCNT - 1;
			}
			histogram_of_ratios[idx]++;
		}	//markers
	} //gene

	// output the observed data
	// if we normalize null and experimental distrib, we can compare distributions
	int j;
	fo = fopen("cis_obs_distrib.txt", "w");
	for (j=0; j<BINCNT; j++ ) {
		//output partN of histogram to file, merge later
		fprintf(fo, "%f\n", histogram_of_ratios[j]);
	}
} //end func

//-----------------------------
//
// calculate the cis correlation of cgh v expr
//
//-----------------------------
void cis_corr(int nsize, double** cgh, double** expr, int** cismarkers){
	int gene, marker;
	double r=0.0;
	FILE* fp = fopen("cis_obs_corr.txt", "w");
	if (fp==NULL)
		err("could not open cis obs corr.txt");
	for (gene = 0; gene < 20996; gene++ ) { 
		fprintf(stderr, "%i\n", gene);
		for (marker = cismarkers[gene][0]; marker < cismarkers[gene][1]; marker++) {
			// gsl correlation
			r = gsl_stats_correlation(cgh[marker], 1, expr[gene], 1, nsize);
			fprintf(fp, "%lf\n", r);
			r=0.0;
		}
	} 
} 

//-----------------------------
//
// calculate the cis correlation of cgh v expr
// using permutation
//-----------------------------
void cis_corr_permute(int nsize, int npermutations, double** cgh, double** expr, int** cismarkers){
	int i,k,gene, marker;
	double r;
	gsl_rng *RNG;
	gsl_permutation *PERM = gsl_permutation_alloc (nsize); // remember to free it
	gsl_rng_env_setup();
	const gsl_rng_type *T;
	T = gsl_rng_default;
	RNG = gsl_rng_alloc(T);
	gsl_permutation_init (PERM);

	FILE* fp = fopen("cis_null_corr.txt", "w");

	//permutation steps
	double *permarray = malloc(nsize * sizeof(double));
	if (permarray==NULL)
		err("failure to allocate permarray");

	for (gene = 0; gene < 20996; gene++ ) { 
		fprintf(stderr, "%i\n", gene);
		for (marker = cismarkers[gene][0]; marker < cismarkers[gene][1]; marker++) {
			for (k=0; k<npermutations; k++ ) {
				gsl_ran_shuffle (RNG, PERM->data, nsize, sizeof(size_t) );
				for (i=0; i< nsize; i++){
					// now we have array of permuted expression data
					/*fprintf(stderr, "%d\t", gsl_permutation_get(PERM,i));
					if (i==(nsize-1))
					fprintf(stderr, "\n");*/
					permarray[i]=expr[gene][gsl_permutation_get(PERM,i)];
				}
				// gsl correlation
				r = gsl_stats_correlation(cgh[marker], 1, permarray, 1, nsize);
				fprintf(fp, "%lf\n", r);
			}
		}
	} //gene
} 

//-----------------------------
//
// Do the regression on cis 
// 
//-----------------------------

void do_cis_regress(){
	int** cis;
	cis = allocate_intgrid(20996,2);
	load_cis(cis);

	double** exprdata, **cghdata;
	exprdata = allocate_grid(20996 , 80);
	cghdata  = allocate_grid(235829, 80);
	if (exprdata==NULL || cghdata==NULL)
		err("cannot allocate grid");
	//load_expr(data);	
	load_data(20996, 80, 
		"/home3/rwang/QTL_comp/final3_log10RHtoA23ratio.txt",
		exprdata);
	//debug_load_expr(20996, 80, exprdata);
	load_data(235829, 80, 
		"/home3/rwang/QTL_comp/g3cghnormalized.txt",
		cghdata);
	//debug_load_expr(235829, 80, cghdata);
	cis_regress(80, cghdata, exprdata, cis);
}

//-----------------------------
//
// run the permutation 
//
//-----------------------------
void do_permute() {
	int** cis;
	cis = allocate_intgrid(20996,2);
	load_cis(cis);

	double** exprdata, **cghdata;
	exprdata = allocate_grid(20996 , 80);
	cghdata  = allocate_grid(235829, 80);
	if (exprdata==NULL || cghdata==NULL)
		err("cannot allocate grid");
	//load_expr(data);	
	load_data(20996, 80, 
		"/home3/rwang/QTL_comp/final3_log10RHtoA23ratio.txt",
		exprdata);
	//debug_load_expr(20996, 80, exprdata);
	load_data(235829, 80, 
		"/home3/rwang/QTL_comp/g3cghnormalized.txt",
		cghdata);
	//debug_load_expr(235829, 80, cghdata);
	permute(80, 50, cghdata, exprdata, cis);
}

//-----------------------------
//
// run the cis correlation and
// correlation permutation
//
//-----------------------------
void do_correlation() {
	int** cis;
	cis = allocate_intgrid(20996,2);
	load_cis(cis);

	double** exprdata, **cghdata;
	exprdata = allocate_grid(20996 , 80);
	cghdata  = allocate_grid(235829, 80);
	if (exprdata==NULL || cghdata==NULL)
		err("cannot allocate grid");
	//load_expr(data);	
	load_data(20996, 80, 
		"/home3/rwang/QTL_comp/final3_log10RHtoA23ratio.txt",
		exprdata);
	//debug_load_expr(20996, 80, exprdata);
	load_data(235829, 80, 
		"/home3/rwang/QTL_comp/g3cghnormalized.txt",
		cghdata);
	//debug_load_expr(235829, 80, cghdata);
	cis_corr(80, cghdata, exprdata, cis);
	cis_corr_permute(80, 50, cghdata, exprdata, cis);
}
//-----------------------------
//
// NEW MAIN
//
//-----------------------------
int main(int argc, char** argv) {
	printf("starting ...");
	do_permute();
	//do_cis_regress();	
	//do_correlation(); 
	printf("done\n");
}

