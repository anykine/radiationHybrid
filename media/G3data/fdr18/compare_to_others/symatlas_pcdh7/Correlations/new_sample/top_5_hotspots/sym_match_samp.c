#include<math.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define CELLS 61
#define TINY 1.0e-20
//#include "nrutil.h"
//#include "nrutil.c"

//void tutest(double data1[], unsigned long n1, double data2[], unsigned long n2,  double *t, double *prob);
//void avevar(double data[], unsigned long n, double *ave, double *var);
//double betai(double a, double b, double x);
//double gammln(double xx);
//void pearsn(double x[], double y[], unsigned long n, double *r);

double pearsn(double x[], double y[], int n)
//Given two arrays x[1..n] and y[1..n], this routine computes their correlation coeﬃcient
//r (returned as r), the signiﬁcance level at which the null hypothesis of zero correlation is
//disproved (prob whose small value indicates a signiﬁcant correlation), and Fisher’s z (returned
//as z), whose value can be used in further statistical tests as described above.
{
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


//total number of cell lines
// this typedef is a way to simplify 2D array creation
// it holds 99 doubles ... one row of data

typedef double RowArrayD[CELLS];

RowArrayD *sym;
int symrows=36118;
int pcdh7count=222;

FILE *fi, *fo;

int main(int argc, char *argv[]) {
	char sym_atlas_file[]="/home/josh/Desktop/symatlas_pcdh7/sym_atlas_unlogged.txt";
	char pcdh7_index_file[]="5_u.txt";

	char pcdh7_avg[]="hp5_u_avg.txt";
	//char null_avg[]="average_correlation_for_samp_null.txt";
	
	int row, col, i,j,k;
	char line[5000];
	char *pch;

	sym = malloc(symrows * CELLS * sizeof(double));
	if(sym==NULL) { printf("Doh\n"); exit(0);}
	fi = fopen(sym_atlas_file, "r");
	if(fi==NULL) {printf ("Doh\n"); exit(0); }
	for (row=0; row<symrows; row++) {
		fgets(line,5000,fi);
		pch = strtok (line, "\t");
		col=0;
		while (pch != NULL) 
		{									
			sym[row][col]=log(atof(pch))/log(2);
			pch = strtok (NULL, "\t\n");
			col++;
		}
	}
	fclose(fi);

	
	int *pcdh7ind;
	pcdh7ind= malloc(pcdh7count * sizeof(int));
	if(pcdh7ind==NULL) {printf("doh\n");}
	
	fi = fopen(pcdh7_index_file, "r");  
	if(fi==NULL) {printf("doh\n");}
	
	row=0;
	while(fgets(line, 30, fi) != NULL) {
		pcdh7ind[row]=atoi(line)-1;
		row++;
	}  
	fclose(fi);


	fo = fopen(pcdh7_avg, "w"); 	if(fo==NULL) {printf("doh\n");}
	double sum=0;
	double a[61], b[61];
	int c;
	int cmb=165600;
	//calculate statistic
	for (i=0; i<pcdh7count-1; i++ ) {
		for (c=0; c<CELLS; c++) { a[c]=sym[pcdh7ind[i]][c]; }
		for (j=i+1; j<pcdh7count; j++ ){
			for (c=0; c<CELLS; c++) { b[c]=sym[pcdh7ind[j]][c]; }
				sum =sum+pearsn(a,b,61);
				fprintf(fo, "%e\n", pearsn(a,b,61));
		}
	}
	fclose (fo);


	/*
	fo = fopen(null_avg, "w"); if(fo==NULL) { printf("doh\n");}
	int sampnum, sampsize, newrand, found; 
	sampnum=0; 	
	while (sampnum<10000){
 		sampsize=0;
		free(pcdh7ind);	
		pcdh7ind= malloc(pcdh7count * sizeof(int));

		pcdh7ind[sampsize]=(rand() % (symrows)); sampsize++; 
		while (sampsize<pcdh7count) {
			found=0;
			newrand=(rand() % (symrows));

			for (c=0; c<sampsize; c++) { 
				if (pcdh7ind[c]==newrand) {found++;} 
			}	

			if (found==0) { 
				pcdh7ind[sampsize]=newrand;
				sampsize++;
			}
		}

		sum=0;
		int run=0;
		for (i=0; i<pcdh7count-1; i++ ) {
				for (c=0; c<CELLS; c++) { a[c]=sym[pcdh7ind[i]][c]; }
			for (j=i+1; j<pcdh7count; j++ ){
				for (c=0; c<CELLS; c++) { b[c]=sym[pcdh7ind[j]][c]; }
				//printf("%d\t%d\t%d\t%e\n", run, pcdh7ind[i], pcdh7ind[j], pearsn(a,b,61));
				 //run++;
				sum =sum+pearsn(a,b,61);
			}
		}
		
		//fprintf(fo, "%e\n", sum/cmb);
		fprintf(fo, "%d\t%e\n", sampnum, sum/cmb);
		sampnum++;
	}
*/
}



