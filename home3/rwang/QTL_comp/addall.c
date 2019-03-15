#include <stdio.h>
#include <stdlib.h>


int main(int argc, char** argv) {
	long long int count = 0;
	long long int count1 = 0;
	float temp = 0;

	FILE* fid = fopen(argv[1], "r");
	if (fid == NULL){
		printf("cannot open file for read\n");
		exit(1);
	}
	while( fscanf(fid, "%f", &temp) >0 ){
		//printf("%f\n",temp);
		count1 = (long long ) temp;
		//printf("%lld\n", count1);
		//printf("%lf\n",temp);
		count = count + count1;
	}

	printf("total sum is %lld\n", count);
}
