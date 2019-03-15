#include <stdio.h>
#include <math.h>
#include <stdlib.h>
// #include <time.h>



int main (int argc, char** argv)
{
	int i;
	FILE *ALPHA_FILE1, *ALPHA_FILE2, *OUT_FILE;
	float count1, count2, count3;
	
	if (argc !=5){
		printf("%s <file1 to read> <file2 to read> <output append1> <output append2>\n", argv[0]);
		exit(1);	
	}
	ALPHA_FILE1= fopen(argv[1], "r");
	ALPHA_FILE2= fopen(argv[2], "r");
	char newout[100] = "alpha_null_counts_merge_";
	strcat(newout, argv[3]);
	strcat(newout, "and");
	strcat(newout, argv[4]);
	//OUT_FILE = fopen("alpha_null_counts_rm_ex_4_and_8.txt", "w");
	OUT_FILE = fopen(newout, "w");
	

for (i = 0; i < 100000000; i++)
{
	fscanf(ALPHA_FILE1, "%f ", &count1);
	fscanf(ALPHA_FILE2, "%f ", &count2);
	count3 = count1 + count2;
	fprintf(OUT_FILE, "%f\n", count3);
	if (i % 1000 == 0)
	{
		printf("%i\n", i);
	}
}



fclose(ALPHA_FILE1);
fclose(ALPHA_FILE2);
fclose(OUT_FILE);
}




