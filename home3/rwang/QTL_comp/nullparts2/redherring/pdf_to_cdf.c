#include <stdio.h>
#include <math.h>
#include <stdlib.h>
// #include <time.h>

int main () {
	int i;
	FILE *fin, *fout;
	double pdf, cdf;
	
	fin = fopen("alpha_null_density.txt", "r");
	if (fin==NULL){
		printf("error opening file\n");
		exit(1);
	}

	fout = fopen("alpha_null_cdf.txt", "w");

cdf = 0;
fscanf (fin, "%lf ", &pdf);
fprintf (fout, "%lf\n", pdf);	
cdf += pdf;

for (i = 1; i < 100000000; i++) {
	fscanf(fin, "%lf", &pdf);
	cdf += pdf;
	
	fprintf(fout, "%lf\n", cdf);
	if (i % 1000 == 0) 
		printf("%i\n", i);
	
}

fclose(fin);
fclose(fout);
}




