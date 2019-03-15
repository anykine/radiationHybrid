#include <fstream>

struct Website{
	char SiteName[100];
	int Rank;
};

int main(){
	FILE *fp;
	fp = fopen("test.bin", "wb");
	char x[10] = "ABCDEFGHIJ";
	fwrite(x, sizeof(x[0]), sizeof(x)/sizeof(x[0]), fp);

}

void write_to_binary(WebSites p_Data){
	fstream binary_file("test.dat", ios::out|ios:binary|ios::app);
	binary_file.write(reinterpret_cast<char *>(&p_Data), sizeof(Website));
	binary_file.close();
}
