#include<stdio.h>
#include<math.h>

#define NUM 18577
/***********************************
take my list of numbers and convert to matrix

the dog files is: marker1 marker2 chisq_pval fdr_pval
***********************************/
int main(){
	FILE* id;
	int a,b,c,i,j;
	float f, g;
	id = fopen("g3_fdr_inorder.txt.e02.filter3", "r");
	if (!id){
		printf("error opening file\n");
		exit(1);
	}
	
	//allocate
	float* matrix[NUM];
	for(i=0; i<NUM; i++){
		matrix[i] = malloc( 9775 * sizeof(float));
	}
	//set to zero
	for (i=0; i<NUM; i++){
		for (j=0; j<NUM; j++){
			matrix[i][j]=1;
		}
	}
	//read in
	//for (i=0; i<20; i++){
		//printf("hi2\n");
	//	fscanf(id, "%d\t%d\t%f\t%f\n", &a, &b, &f, &g);
	while (fscanf(id, "%d\t%d\t%f\t%f\n", &a, &b, &f, &g) > 0){
		matrix[a-1][b-1] = g;
		//printf("%d\t%d\t%e\t%e\n", a, b, f,g);
	}
	fclose(id);


	//output
	
	id = fopen("dog_fdr_inorder.e02.mat", "w");
	for (i=0; i<NUM; i++){
		for (j=0; j<NUM; j++){
			if (j == NUM-1) {
				fprintf(id, "%e\n", matrix[i][j]);
			} else {
				fprintf(id, "%e\t", matrix[i][j]);
			}
		}
		//printf("\n");
	}

}
