#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
int chomp(char*);

int main(void){
	FILE *fin = fopen("test.txt", "r");
	int row = 0;
	char line[5000];
	while(fgets(line, 5000, fin) != NULL){
	if (chomp(line)){
		printf("row=%d\t%s\n", row,line);
		row++;
	}
	if (row % 5 == 0){
		printf("hi %d\n", row);
	}
	}

}

int chomp(char* s){
	int chomped=0;
	char *p = strchr(s, '\n');
	if (p != NULL){
		*p = '\0';
		chomped = 1;
	}
	return chomped;
}
