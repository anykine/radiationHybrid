// learned to use argv in C

#include <stdio.h>

int main(int argc, char* argv[]) {
	int i;
	if (argc < 2){
		//printf("no input\n");
		printf("usage: %s <file to read>\n",argv[0]);
		return 0;
	}
	fprintf(stdout, "the number of command line arguments is %d\n", argc);
	fprintf(stdout, "The program name is %s\n", argv[0]);
	for (i=1; i<argc; i++) {
		fprintf(stdout, "%s\n", argv[i]);
	}
	fprintf(stdout, "\n");
	return 0;
}
