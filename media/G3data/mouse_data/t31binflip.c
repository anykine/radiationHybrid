#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*--------------------------------------------------------------------
 * Converts T31 alpha/nlp data to binary format (alp_grid_scaled.txt,
 * nlp_grid.txt)
 *  No guarantee that this is multi-platform compatible
 *
 * Expects input format: 
 *  232626 rows, each with 20145 columns 
 *  
 *
 *  Binary format is 
 *  -records stored as 4byte floats
 *  ----------------------------------------------------------------*/

// each gene-marker pair
struct record {
	int gene_id;
	int marker_id;
	float mu;
	float alpha;
	float nlp; /* neg log p*/
};

// ident info for file
// size of struct may not be sum or parts
struct head{
	unsigned int headersize;
	char type[8];
	unsigned int num_genes;
	unsigned int num_markers;
	unsigned long int num_entries;
};

void printhelp(char* prog){
	printf("\n\n");
	printf("Usage: %s [opts] <file to convert>\n\n", prog);
	printf(" -b <ascii> <binout> create binary file from ascii (with .bin)\n");
	printf(" -d dump binary file \n");
	printf("This will take the mouse T31 alpha/nlp grid files and convert it to binary format.\n");
	printf("Output filename is <inputname>.bin\n\n");
	exit(1);
}
void err(char* s){
	printf("**%s\n", s);
	printf("**exiting...\n");
	exit(1);
}

int writeheader(FILE* fout){
	struct head header;
	header.headersize = sizeof(struct head);
	strncpy(header.type, "T31RW101",8);
	header.num_genes = 20145;
	header.num_markers = 232626;
	header.num_entries = 4686250770; /* this should be calcuated instaed of hardcoded*/ 
	fprintf(stderr, "size of header is %d\n", sizeof(header));
	if (fwrite((void *)&header, sizeof(header), 1, fout)){
		return 1;
	} else {
		return 0;
	}
}

void printheader(struct head* header){
	if (header==NULL){
		err("nothing in struct header");
	}
	printf("header output\n");
	printf("size of header is %d\n", sizeof(struct head));
	printf("type=%s\n", header->type);
	printf("num_genes=%d\n", header->num_genes);
	printf("num_markers=%d\n", header->num_markers);
	printf("num_entries=%ld\n", header->num_entries);
}

int readheader(FILE* fin, struct head* header ){
	fread(header, sizeof(struct head), 1, fin);
	printheader(header);	
}
//
//create the BIN file from the ASCII
int convert2bin(char* file, char* binout){
	int counter=0, counter2=0 ;
	FILE* fin = fopen(file, "r");
	if (fin==NULL) {
		err("cannot open input file");
	}
	char* fileout = strcat(binout, ".bin");
	
	FILE *fout = fopen(fileout, "wb");
	if (fout==NULL){
		err("cannot open output file");
	}
	//writeheader(fout);

	//the multiplication by log10(3/2)/log10(2) has more sigfigs than
	//orig data, so the line buffer is made huge to prevent problems
	char line[500001];
	char *pch;
	float value = 0;
	int row=0;

	// read all rows in file, parse and output as binary
	for (row = 0; row < 232626; row++){ 
		fgets(line,500000,fin); 
		pch = strtok (line, "\t");
		while (pch != NULL) {		
			value = atof(pch);
			//printf("%f\n", value);
			fwrite((void *)&value, sizeof(float), 1, fout);
			pch = strtok (NULL, "\t\n");
			if (counter%1000000 ==0){
				printf("%d\n", counter2++);
			}
			counter++;
		}
	}

	fclose(fin);
	fclose(fout);
	return 1;
}

void printrec(struct record* rec){
	if (rec==NULL) {
		err("rec empty");
	}
	printf("--record\n");
	printf("gene_id=%d\n", rec->gene_id);
	printf("marker_id=%d\n", rec->marker_id);
	printf("mu=%f\n", rec->mu);
	printf("alpha=%f\n", rec->alpha);
	printf("nlp=%f\n", rec->nlp);
}

/**********************************************
 dumpbin

 dump the contents of a G3 binary file

 On my linux64 system, a long int is 8 bytes,
 so it can handle the 4.9 billion lines of data.
 ftell returns a position that is a long, seems ok
 but can't guarantee on other systems.
*********************************************/
int dumpbin(char* file){
	FILE* fbin = fopen(file, "rb");
	long lOffset = 0L;
	if (fbin==NULL){
		err("cannot open input file");
	}	
	//struct head header;
	//struct record rec;
	//readheader(fbin, &header); /*read header,store in struct*/
	float value = 0.0;
	lOffset = ftell(fbin);
	printf("current offset = %ld\n", lOffset);

	//dumping specific entries
	long long int i=0;
	int num=0;
	//for (i=0; i<20145*2; i=i+4){
	for (i=18238880100; i< 18238960682; i=i+4){
		//fread(&value, sizeof(float), 1, fbin);
		//fseek(fbin, sizeof(float),1);
		num = fseek(fbin, i, 0);
		if (num != 0) {
			err("cannot seek this position");
		}

		num= fread(&value, sizeof(float), 1, fbin);
		if (num < 1) {
			err("did not get all data");
		}
		printf("num read %d\n", num);
		printf("%f\n", value);
	}
/*
	lOffset = ftell(fbin);
	printf("after seeek current offset = %ld\n", lOffset);

	fread(&rec, sizeof(struct record), 1, fbin);
	printrec(&rec);
	lOffset = ftell(fbin);
	printf("current offset = %ld\n", lOffset);
	printf("sizeof record = %d\n", sizeof(struct record));
*/
}

int write_blank_file(){
	FILE* fout = fopen("/drive2/alp_grid_scaled2.bin", "wb");	
	if (fout==NULL){
		err("cannot open output file");
	}
	//writeheader(fout);
	long int ii = 0;
	long int jj = 0;
	//long long int total = 232626*20145;
	float dummy = 0.0;
	for	(ii=0; ii< 20145; ii++){
		for(jj=0; jj<232626; jj++){
			fwrite((void *)&dummy, sizeof(float), 1,fout);
		}
	}
	
	fclose(fout);
	return 1;
}

int flip_matrix(){
	FILE* fileout = fopen("/drive2/alp_grid_scaled2.bin", "wb");
	FILE* filein = fopen("alp_grid_scaled.bin", "rb");
	long counter=0;
	long address1=0L;
	long address2=0L;
	long int i=0;
	long int i2=0;
	int ret;
	float data[20145];
	for(i=0; i<232626; i++){
		address1 = sizeof(float)*(i)*(20145);
		ret = fseek(filein, address1, 0);		
		if (ret != 0)
			err("can't seek");
		ret = fread(data, sizeof(float), 20145, filein);
		if (ret != 20145)
			err("read less than full");
		for(i2=0; i2<20145; i2++){
			address2 = sizeof(float)*(i2*232626 + i);
			//printf("ad2 = %ld\n", address2);
			
			ret = fseek(fileout, address2, 0);
			if (ret != 0)
				err("can't seek 2");
			fwrite(&data[i2], sizeof(float), 1, fileout);
			
		}
		
			printf("%ld\n", counter++);
	}
	return 1;
}

int main(int argc, char* argv[]) {
	/*if (argc != 3 && argc !=4) { 
		printhelp(argv[0]);
	}
	*/
	int r;
	
//	r = write_blank_file();
//	if (r)
//		printf("done writing file\n");
	r = flip_matrix();
	if (r)
		printf("done flipping file\n");
	//simple scan command line args
	// -b textfile.txt
	// -d binfile.bin

	/*
	int i;
	for (i=1; i<argc; i++){
		if (strcmp(argv[i], "-b") == 0 ){
			printf("running convert on %s\n", argv[i+1]);
			convert2bin(argv[i+1], argv[i+2]);
		}
		if (strcmp(argv[i], "-d") == 0){
			printf("running dump on %s\n", argv[i+1]);
			dumpbin(argv[i+1]);
		}
	}
	*/
	//convert2bin(argv[1]);	
	//dumpbin(argv[1]);
	
}

