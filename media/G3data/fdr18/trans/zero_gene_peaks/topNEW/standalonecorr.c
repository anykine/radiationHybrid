#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_cdf.h>

/***********************************************************************
 *
 *
 *
 *  Using the tdist from GSL
 *
 *  Inputs: pearson correlation coefficient r
 *          degrees of freedom (N-2)
 *
 *  *********************************************************************/
double corr_pvalue(double pearson_corrcoef, double df){
	if (df < 0)
		err("degrees of freedom is unreasonable");
	if (pearson_corrcoef > 1 || pearson_corrcoef < -1)
		err("correlation is out of bounds");
	
	
	// calculate the statistic S from this equation
	double s = 1.0 * pearson_corrcoef * sqrt(df)/(sqrt(1-pow(pearson_corrcoef, 2)));
	printf("s is %lf df is %lf\n", s, df);
	
	// s follows a t-distribution, using 1-cumulative_dist
	// and only gives a one-sided test
	double pval = gsl_cdf_tdist_Q (s,  df) ;
		
	// to get the 2-sided test, you need to multiple x2
	// but the quantile of s may be greater than 0.5, so 
	// adjust accordingly
	
	if (pval < 0.5){
		pval = 2.0*pval;
	} else {
		pval = 2.0*(1-pval);
	}
	// the pvalue could be divided by two if two-tailed test.
	//printf("pvals is %lf\n", pval);
	return pval;
}

/***************************************
 *
 *
 *
 *  wikipedia correlation
 *
 *  *************************************/
int main(int argc, char* argv[]){

	double sum_sq_x=0.0;
	double sum_sq_y=0.0;
	double sum_coproduct = 0.0;
	double mean_x=0.0;
	double mean_y=0.0;
	double sweep=0;
	double x=0.0;
	double y=0.0;
	double pop_sd_x = 0.0;
	double pop_sd_y = 0.0;
	double cov_x_y = 0.0;
	double delta_x=0.0;
	double delta_y=0.0;
	double junk1, junk2;

	FILE* fp = fopen(argv[1], "r");
	if (fp==NULL){
		fprintf(stderr, "cannot open file %s\n", argv[1]);
		exit(1);
	}

	// read in the first line and set to mean_x/y
	fscanf(fp, "%lf %lf %lf %lf", &mean_x, &junk1, &mean_y, &junk2);

	// need to start counter at 2 because we already
	// read in the 1st line
	long int counter=1;
	while(fscanf(fp, "%lf %lf %lf %lf", &x, &junk1, &y, &junk2)!= EOF){
		++counter;
		sweep = (counter - 1.0)/counter;
		delta_x =  x - mean_x;
		delta_y =  y - mean_y;
		sum_sq_x = sum_sq_x + (delta_x * delta_x * sweep);
		sum_sq_y = sum_sq_y + (delta_y * delta_y * sweep);
		sum_coproduct = sum_coproduct + (delta_x * delta_y * sweep);
		mean_x = mean_x + delta_x/counter;
		mean_y = mean_y + delta_y/counter;
		//counter++;
	}
	printf("counter is %ld\n", counter);
	pop_sd_x = sqrt( sum_sq_x/counter);
	pop_sd_y = sqrt( sum_sq_y/counter);
	cov_x_y = sum_coproduct/counter;
	float correlation = cov_x_y/(pop_sd_x * pop_sd_y);
	printf("correlation is %f\n", correlation);
	printf("pvalue is %.100e\n", corr_pvalue((double)correlation, counter-2));	
}
