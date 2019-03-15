/* $Log: chisq.c,v $
/* Revision 1.7  2006/07/17 03:48:47  rwang
/* -mremoved idx= from output
/*
/* Revision 1.6  2006/04/29 00:41:17  rwang
/* chisq.c
/*
/* Revision 1.5  2006/04/28 23:22:20  rwang
/* chisq.c
/*
/* Revision 1.4  2006/04/28 19:35:01  rwang
/* added log to top of file
/* */
///////////////////////////////////////
//
// based on numerical recipes www.nr.com
// some source: www.nr.com/public-domain.html
// Usage directions are in Chapt 1.2
//
///////////////////////////////////////

#include <math.h>
#include <stdio.h>
#include "nrutil.h"
#include "nrutil.c"

#define TINY 1.0e-30
#define ITMAX 100
#define EPS 3.0e-7
#define FPMIN 1.0e-30

//prototypes
void cntab1(int **nn, int ni, int nj, float *chisq, float *df, float *prob,
	float *cramrv, float *ccc) ;

int main(int argc, char* argv[]) {
	float chisq, df, prob, cramrv, ccc;
	int **a;
	FILE *fp;

	if(argc < 2) {
		printf("usage: %s <file to read>\n", argv[0]);
		return 1;
	}

	fp = fopen(argv[1], "r");
	// check pointer is NOT NULL
	if (fp == 0) {
		printf("Could not open file\n");
		return 1;
	} else {
		int data11, data10,data01,data00,idx1,idx2;
		while (fscanf(fp, "%d %d %d %d %d %d",&data11,&data10,&data01,&data00,&idx1,&idx2 ) != EOF) {

		/*printf("data11 = %d\n", data11);
		printf("data10 = %d\n", data10);
		printf("data01 = %d\n", data01);
		printf("data00 = %d\n", data00);
		printf("idx1= %d\n", idx1);
		printf("idx2= %d\n", idx2);
		*/
		// use nrutil.h library functions to create
		// the desired matrix (cf. Chapt 1.2)
		// array is 1 based, not 0 based
		a=imatrix(1,2, 1,2);
		a[1][1] = data11;
		a[1][2] = data01;
		a[2][1] = data10;
		a[2][2] = data00;
	
		cntab1(a, 2, 2, &chisq, &df, &prob, &cramrv, &ccc	);
		free_imatrix(a, 1, 2, 1, 2);
		//prints to stdout
		//print marker_1, marker_2, pvalue
		printf("%d\t%d\t%g\n", idx1,idx2,prob);
		}//while

	}
}

/* chi square 
	Given a 2d contingency table in the form of array nn[1..ni][1..nj]
	this returns 
	the chi-square: chisq
	degrees freedom: df
	significance: prob
	and two measures of association: 
	Cramer's V: cramrv
	contingency coefficient C: ccc

*/
void cntab1(int **nn, int ni, int nj, float *chisq, float *df, float *prob,
	float *cramrv, float *ccc) 
{
	float gammq(float a, float x);
	int nnj, nni, j, i, minij;
	float sum=0.0, expctd, *sumi, *sumj, temp;

	sumi=vector(1,ni);
	sumj=vector(1,nj);
	nni=ni; //num of rows
	nnj=nj; //num of columns

	//get the row totals
	for (i=1; i<=ni; i++){
		sumi[i]=0.0;
		for (j=1; j<=nj; j++) {
			//printf("i=%d j=%d, nn is %d\n", i,j,nn[i][j]);
			sumi[i] += nn[i][j];
			sum += nn[i][j];
		}
		if (sumi[i] ==0.0) --nni;  //elim zero rows
	}

	//get the col totals
	for (j=1; j<=nj; j++) {
		sumj[j]= 0.0;
		for (i=1; i<=ni; i++) sumj[j] += nn[i][j];
		if (sumj[j] == 0.0) --nnj; //elim zero cols
	}
	*df=nni*nnj-nni-nnj+1; //correct num of degrees freedom
	*chisq = 0.0;

	//do the chi square sum
	for (i=1; i<=ni; i++) {
		for (j=1; j<=nj; j++) {
			expctd = sumj[j]*sumi[i]/sum;
			temp = nn[i][j] - expctd;
			//TINY guarantees that any elim row or col will
			//not contribute to the sum
			*chisq += temp*temp/(expctd+TINY); 
		}
	}
	//chi square probibility function
	*prob = gammq(0.5*(*df), 0.5*(*chisq));
	minij = nni < nnj ? nni-1 : nnj-1;
	*cramrv = sqrt(*chisq/(sum*minij));
	*ccc = sqrt(*chisq/(*chisq+sum));
	free_vector(sumj,1,nj);
	free_vector(sumi,1,ni);
}

/* returns incomplete gamma function 
    Q(a,x) = 1-P(a,x)
*/
float gammq(float a, float x) 
{
	void gcf(float *gammcf, float a, float x, float *gln);
	void gser(float *gamser, float a, float x, float *gln);
	void nrerror(char error_text[]);
	float gamser, gammcf, gln;

	//if (x < 0.0 || a <= 0.0) nrerror("Invalid arguments in routine gammq");
	// above crashes when vec1=101010 and vec2=000000, so I am forcing
	// this func to return 0 for probability in output
	if (x < 0.0 || a <= 0.0) return 0;
	
	if (x < (a+1.0)) { 			// use the series representation
		gser(&gamser,a,x,&gln);
		return 1.0-gamser;		//take its complement
	} else {								// use the continued fraction representation
		gcf(&gammcf,a,x,&gln);
		return gammcf;
	}
}

/*
	Returns imcomplete gamma function P(a,x) evaluated by
	its series representation as gamser. Also returns
	ln(gamma(a)) as gln
*/
void gser(float *gamser, float a, float x, float *gln) {
	float gammln(float xx);
	void nrerror(char error_text[]);
	int n;
	float sum, del, ap;

	*gln=gammln(a);
	if (x <= 0.0) {
		if (x < 0.0) nrerror("x less than 0 in routine gser");
		*gamser = 0.0;
		return;
	} else {
		ap=a;
		del=sum=1.0/a;
		for (n=1; n<=ITMAX; n++) {
			++ap;
			del *= x/ap;
			sum += del;
			if (fabs(del) < fabs(sum)*EPS) {
				*gamser=sum*exp(-x+a*log(x)-(*gln));
				return;
			}
		}
		nrerror("a too large, ITMAX too small in routine gser");
		return;
	}
}

/*
	Returns the incomplete gamma function Q(a,x) evaluated by
	its continued fraction representation as gammcf. Also
	returns ln(gamma(a)) as gln.
*/
void gcf(float *gammcf, float a , float x, float *gln) {
	float gammln(float xx);
	void nrerror(char error_text[]);
	int i;
	float an,b,c,d,del,h;

	*gln=gammln(a);
	b=x+1.0-a;							//setup for eval continued fraction
													//by modified Lentz's method with b_0=0
	c=1.0/FPMIN;
	d=1.0/b;
	h=d;
	for (i=1;i<=ITMAX; i++){		//iterate to convergence
		an = -i*(i-a);
		b += 2.0;
		d=an*d+b;
		if (fabs(d) < FPMIN) d=FPMIN;
		c=b+an/c;
		if (fabs(c) < FPMIN) c=FPMIN;
		d = 1.0/d;
		del=d*c;
		h *=del;
		if(fabs(del-1.0) < EPS) break;
	}
	if (i > ITMAX) nrerror("a too large, ITMAX too small in gcf");
	*gammcf=exp(-x+a*log(x)-(*gln))*h; //put factors in front
}

/*
	Returns the value ln(gamma(xx)) for xx > 0

*/
float gammln(float xx) {
	double x, y, tmp, ser;
	static double cof[6] = {76.18009172947146, -86.50532032941677,
		24.01409824083091, -1.231739572450155,
		0.1208650973866179e-2, -0.5395239384953e-5};
	int j;

	y=x=xx;
	tmp=x+5.5;
	tmp -= (x+0.5)*log(tmp);
	ser = 1.000000000190015;
	for (j=0; j<=5; j++) ser += cof[j]/++y;
	return -tmp+log(2.5066282746310005*ser/x);
}
