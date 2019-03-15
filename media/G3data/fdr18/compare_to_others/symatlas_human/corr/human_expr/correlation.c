#include<math.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define CELLS 80 
#define ROWS 12368
#define TINY 1.0e-20
//#include "nrutil.h"
//#include "nrutil.c"

//void tutest(double data1[], unsigned long n1, double data2[], unsigned long n2,  double *t, double *prob);
//void avevar(double data[], unsigned long n, double *ave, double *var);
//double betai(double a, double b, double x);
//double gammln(double xx);
//void pearsn(double x[], double y[], unsigned long n, double *r);

/* ----------------------------------------------------------
 Pearson Correlation
 from Numerical Recipes in C
 ----------------------------------------------------------*/
double pearsn(double x[], double y[], int n){
//Given two arrays x[1..n] and y[1..n], this routine computes their correlation coeﬃcient
//r (returned as r), the signiﬁcance level at which the null hypothesis of zero correlation is
//disproved (prob whose small value indicates a signiﬁcant correlation), and Fisher’s z (returned
//as z), whose value can be used in further statistical tests as described above.
    // double betai(double a, double b, double x);
     int j;
     double yt,xt,t,df;
     double syy=0.0,sxy=0.0,sxx=0.0,ay=0.0,ax=0.0;
           //                          Find the means.
     for (j=1;j<=n;j++) {
         ax += x[j-1];
         ay += y[j-1];
     }
     ax /= n;
     ay /= n;
//	 cout << ax << "\t" << ay << endl;
         //                            Compute the correlation coeﬃcient.
     for (j=1;j<=n;j++) {
         xt=x[j-1]-ax;
         yt=y[j-1]-ay;
         sxx += xt*xt;
         syy += yt*yt;

         sxy += xt*yt;
     }
     //*r=sxy/(sqrt(sxx*syy)+TINY);
    return(sxy/(sqrt(sxx*syy)+1.0e-20)); 
	 
//                                                         Fisher’s z transformation.
/*     *prob=erfcc(fabs((*z)*sqrt(n-1.0))/1.4142136)               */
//For large n, this easier computation of prob, using the short routine erfcc, would give approx-
//imately the same value.
}

void* err(char* msg){
	printf("%s\n", msg);
	exit(-1);
}

/* ----------------------------------------------------------
		Global vars

 ----------------------------------------------------------*/
//total number of cell lines
// this typedef is a way to simplify 2D array creation
// it holds 99 doubles ... one row of data

typedef double RowArrayD[CELLS];

RowArrayD *sym;
int symrows=12368;
//int symrows=10;


/* ----------------------------------------------------------
	 MAIN 	

 ----------------------------------------------------------*/
int main(int argc, char *argv[]) {
	
	int row, col, i,j,k;
	char line[5000];
	char *pch;

	// read in file
	sym = malloc(symrows * CELLS * sizeof(double));
	if(sym==NULL) 
		err("cannot alloc matrix");	
	FILE* f = fopen("human_expr_final_common.txt", "r");
	//FILE* f = fopen("top10", "r");
	if(f==NULL)
		err("cannot open file");

	for (row=0; row<symrows; row++) {
		fgets(line,5000,f);
		pch = strtok (line, "\t");
		col=0;
		while (pch != NULL) {									
			// skip the first column
			if (col!=0){
				//printf("%d \n", col);
				sym[row][col-1]=atof(pch);
				pch = strtok (NULL, "\t\n");
			} else {
				//printf("crap\n");
				pch = strtok (NULL, "\t\n");
			}
			col++;
		}
	}
	fclose(f);

	// check output
	/*for (row=0; row < 10; row++){
		for (col=0; col <80; col++){
			printf("%f\t",sym[row][col]);
		}
		printf("\n");
	}*/

	// store the data
	/*typedef double RowArrayD[ROWS];
	RowArrayD *corrmatrix;
	corrmatrix = malloc(symrows * ROWS * sizeof(double));*/
	// -------------------------
	// do pearson, write as one long vector, 
	// calculate only half the matrix to save space
	// -------------------------
	double x[CELLS];
	double y[CELLS];
	int row1=0, row2 = 0;
	for (row1=0; row1<symrows; row1++){
		for (row2=0; row2<=row1; row2++){
			for (col=0; col<CELLS; col++){	
				x[col] = sym[row1][col];
				y[col] = sym[row2][col];
				//printf("%f ", x[col]);
			}
			//printf("\n");

			double res = pearsn(x, y, CELLS);
			printf("%f\n", res);
			//corrmatrix[row1][row2];
		}
	}
}



