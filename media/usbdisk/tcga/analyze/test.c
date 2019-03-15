#define __GSL__
#include <stdio.h>
#if defined __GSL__
#include <gsl/gsl_fit.h>
#include <gsl/gsl_statistics.h>
#endif

int main(void){
	FILE *fin;
	fin = fopen("testx", "r");
	double x[237];	
	double y[237];	
	int i=0;
	for (i = 0; i<237; i++){
		fscanf(fin, "%lf", &x[i]);
	}
	fclose(fin);
	fin = fopen("testy", "r");
	for (i=0; i<237; i++){
		fscanf(fin, "%lf", &y[i]);
	}
	double r = gsl_stats_correlation(x, 1, y, 1, 237);
	printf ("r is %lf\n", r);
}


int testmain(void){
	int i, n=4;
	double x[4] = {1970, 1980, 1990, 2000};
	double y[4] = {12, 11, 14, 13};
	double w[4] = {0.1, 0.2, 0.3, 0.4};

	double c0, c1, cov00, cov01, cov11, chisq;

gsl_fit_wlinear (x, 1, w, 1, y, 1, n, 
                &c0, &c1, &cov00, &cov01, &cov11, &chisq);
     
	printf ("# best fit: Y = %g + %g X\n", c0, c1);
       printf ("# covariance matrix:\n");
        printf ("# [ %g, %g\n#   %g, %g]\n", 
               cov00, cov01, cov01, cov11);
        printf ("# chisq = %g\n", chisq);
     
        for (i = 0; i < n; i++)
         printf ("data: %g %g %g\n", 
                         x[i], y[i], 1/sqrt(w[i]));
      
       printf ("\n");
      
       for (i = -30; i < 130; i++)
          {
           double xf = x[0] + (i/100.0) * (x[n-1] - x[0]);
            double yf, yf_err;
     
            gsl_fit_linear_est (xf, 
                               c0, c1, 
                                cov00, cov01, cov11, 
                               &yf, &yf_err);
      
           printf ("fit: %g %g\n", xf, yf);
            printf ("hi : %g %g\n", xf, yf + yf_err);
           printf ("lo : %g %g\n", xf, yf - yf_err);
          }
       return 0;
      }

