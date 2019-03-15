#include <stdio.h>
#include <stdlib.h>


//read the args
// -mouse, -human
int main(int argc, char* argv[]){
	char *s ;
	int i=0;
	printf("number of args is %d\n", argc);
	for (i=1; i<argc; i++){
		printf("arg is %s\n", argv[i]);
		if (argv[i][0] == '-') {
			switch (argv[i][1]) {
				case 'm':
					printf("mouse\n");
					break;
				case 'h':
					printf("human\n");
					break;
				default:
					printf("unknown\n");
					printf("%c\n", argv[i][0]);
			}
		}
	}
}
