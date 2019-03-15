#include <stdio.h>
#include <assert.h>

int main(){
	int i;
	i = 2;
	printf("%d\n", i);
	int j = i << 2;
	printf("%d\n", j);
	FILE* f = fopen("test.out", "wb");
	fwrite(&j, sizeof(j),1, f );
	printf("%d", sizeof(int*));
}
