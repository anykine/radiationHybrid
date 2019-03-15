#include <stdio.h>
/* playing with Matlab 5 mat files
*/
int main(int argc, char** argv) {
	//printf("%s", argv[1]);
	FILE *fp;
	int i;
	fp = fopen(argv[1], "rb");
	if (fp==NULL) exit(1);
	char c;
	printf("first 116 txt\n");
	for (i=0; i<116; i++){
		fread((char*) &c, sizeof(char), 1, fp);
		printf("%c",c);
	}
	//header offset data
	for (i=0; i<8; i++){
		fread((char*) &c, sizeof(char),1,fp);	
	}
printf("size of int %d", sizeof(unsigned int));	
	//2-16bit fields
	unsigned int fld;
	unsigned int version, endian;
	fread((int*) &fld, sizeof(int), 1, fp);
printf("\nfld=%d", fld);	
	version = fld && 0xFFFF0000 ;
	//version = version >> 16;
printf("\nversion=%c", version);	
	endian = fld && 0xFF;
printf("\nendian=%c", endian);	
unsigned int j = 65280;
int test = j&&0xFFFF0000;
//test = test >> 16;
printf("test=%d",test);
}
