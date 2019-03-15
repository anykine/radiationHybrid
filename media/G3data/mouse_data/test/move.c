#include <stdio.h>
#include <stdlib.h>

int write(){
	float data[10];
	data[0] = 1.000;
	data[1] = 2.000;
	data[2] = 3.000;
	data[3] = 4.000;
	data[4] = 5.000;
	data[5] = 6.000;
	data[6] = 7.000;
	data[7] = 8.000;
	data[8] = 9.000;
	data[9] = 10.000;
	FILE* fin = fopen("rwtest.bin", "wb");
	fwrite(data, sizeof(float), 10, fin);
	fclose(fin);
}

int read(){
	FILE* fin = fopen("rwtest.bin", "rb");
	long offset =0L;
	float f=0.0;
	long ii=0;
	fseek(fin, 0, 0);
	printf("pos is %ld\n", ftell(fin));
	
	for (ii=0; ii<5; ii++){
		//fseek(fin, sizeof(float), 1);
		printf("before read pos is %ld\n", ftell(fin));
		fread(&f, sizeof(float), 1, fin);
		printf("float is %f\n", f);
		printf("after read pos is %ld\n", ftell(fin));
	}
}
int main() {
	write();
	read();
}
