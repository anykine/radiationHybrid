#include <stdio.h>
#include <math.h>
#include <stdlib.h>
// #include <time.h>





int main ()
{
	int i;
	FILE *ALPHA_FILE1, *ALPHA_FILE2, *OUT_FILE;
	float count1, count2, count3;
	
	ALPHA_FILE1= fopen("alpha_null_counts_rm_ex_4.txt", "r");
	ALPHA_FILE2= fopen("alpha_null_counts_rm_ex_8.txt", "r");
	OUT_FILE = fopen("alpha_null_counts_rm_ex_4_and_8.txt", "w");
	

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




