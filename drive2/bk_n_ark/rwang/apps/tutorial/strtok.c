//////////////////////////////////////////
//
// borrowed from comp.lang.c FAQ list
// http://c-faq.com/lib/strok.html
//
// learned to use: strtok (tokenizer)
//  which is hard to use
//
// learned routine from FAQ to breakup
//  input into array
//////////////////////////////////////////
//
#include <stdio.h>
#include <string.h>
#include <ctype.h>

//prototypes
void use_strtok(void);

int main() {
	//use_strtok();
	
	//calling makeargv
	char string[] = "this is a test give 6 7 8 9 0 11\0";
	char *av[10];
	int i, ac=makeargv(string, av, 10);
	printf("beginning output in main:\n");
	for(i=0; i<ac; i++)
		printf("\"%s\"\n", av[i]);
}

// argvsize is the number of arguments you expect
// which needs to match size of av array in main()
int makeargv(char* string, char* argv[], int argvsize){
	char* p=string;
	int i;
	int argc = 0;
	printf("printing string first\n");
	i=0;
	/*for (i=0; i<10; i++){
		printf("val %d is %c\n", i, *(p+i));
		i++;
		//printf("val %d is %s", i, *(p+i));
	}*/
	printf("end printing string first\n");
	for(i=0; i<argvsize; i++){
		/* skip leading whitespace */
		while(isspace(*p)){
			p++;
			printf("skippingspace\n");
		}
		if(*p != '\0') {
			printf("saving pointer to array\n");
			argv[argc++] = p;
		} else {
			printf("encountered NULL\n");
			argv[argc] = 0;
			break;
		}
		/* scan over arg
				look for next space 
		*/
		while(*p != '\0' && !isspace(*p)) {
			printf("scanning\n");
			p++;
		}
		/* terminate arg 
				found next space	
		*/
		if(*p != '\0' && i < argvsize-1){
			printf("how often is this called\n");
			//write in a null where the space was
			//makes sure while isspace(*p) isn't called
			//if this wasn't here, the print loop in main()
			//would print the entire string again
			//eg. arg1 arg2 arg3
			//    arg2 arg3
			//		arg3
			*p++ = '\0';
		}
	}
	return argc;
}

void use_strtok(void) {
	char string[] = "this is a test";
	char *p;
	for (p=strtok(string, " \t\n"); p!=NULL; p=strtok(NULL, " \t\n"))
	printf("\"%s\"\n", p);
}
