#include <stdio.h>
#include <stdlib.h>

//convert frequency of counts per bin to density 
int main(void){
	FILE *fin, *fout;
	fin = fopen("alpha_null_counts_merge_123and45","r");
	if (fin==NULL){
		printf("error opening file for read\n");
		exit(1);
	}
	fout = fopen("alpha_null_density.txt","w");

	double divisor = 20996.0*235829*5;  //tot number of permutations
	printf("divisor is %lf", divisor);
 	double temp = 0.0;
	int i;	
	for (i = 0; i <100000000; i++){
		fscanf(fin,"%lf", &temp);
		//printf("%lf\n",temp);
		fprintf(fout, "%lf\n", temp/divisor);
	}

	if (i %1000 ==0)
		printf("%i\n",i);
}
