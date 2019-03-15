/*****************************************
extract all pvals for a given marker

purpose: instead of storing in DB, parse
output file. Hoping this is faster

*****************************************/
#include <stdio.h>
#include <string.h>
#include <math.h>
#define RAT_MAX_MARKER 20687

int main(int argc, char* argv[]){
	FILE *fp;
	char Buffer[256];

	int idx1, idx2, marker;
	double prob;
	const char delim[] = "=";
	char *token1, *token2, *token3;
	int seen = 0;
	char m1[12], m2[12], pval[80];

	if (argc < 3) {
		printf("usage: %s <file to read> <marker to find>\n", argv[0]);
		return 1;
	}
	fp = fopen(argv[1], "r");
	if (fp==0){
		printf("Could not open file\n");
		return 1;
	} else {
		while (fscanf(fp, "%s %s %s",m1,m2,pval ) != EOF){
			if (seen == RAT_MAX_MARKER) {
				break;
			}
			//2 calls to get number
			token1 = strtok(m1, delim); //contains idx
			token1 = strtok(NULL, delim); //contains number
			token2 = strtok(m2, delim);
			token2 = strtok(NULL, delim);
			token3 = strtok(pval, delim);
			token3 = strtok(NULL, delim);

			/*
			printf("token1=%s\n", token1);
			printf("token2=%s\n", token2);
			printf("token3=%s\n", token3);
			*/

			idx1 = atoi(token1);
			idx2 = atoi(token2);
			marker = atoi(argv[2]);
			/*
			printf("int idx1=%d\n", idx1);
			printf("int idx2=%d\n", idx2);
			printf("prob=%s\n", token3);
			*/
			//prob = strtod(token3, NULL);
			//sscanf(token3, "%f", &prob);
			//prob = atof(token3);
			if (idx1 == marker) {
				printf("%d\t%d\t%s\n", idx1, idx2, token3);
				seen++;
			}
			if (idx2==marker) {
				if (idx1 != idx2) {
					printf("%d\t%d\t%s\n", idx1, idx2, token3);
					seen++;
				}
			}
			// pval seems to be problematic but
			// ignore this for now
			/*if (prob < 0.0000000000000000001){
				printf("int prob=%G\n", prob);
			}*/

		}//while
	}
}

