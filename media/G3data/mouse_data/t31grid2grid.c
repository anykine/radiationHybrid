#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*--------------------------------------------------------------------
 * Converts T31 alpha/nlp binary format (alp_grid_scaled.bin,
 * nlp_grid.bin) that are 232626rows, 20145 cols into a series of 20
 * text files that are each 20145 rows, 12000/4626 cols. These will
 * later be merged into one file. This is necessary to get human and mouse data
 * files to be in the same order.
 *
 *  No guarantee that this is multi-platform compatible
 *
 * Expects input format: 
 *  232626 rows, each with 20145 columns 
 *  
 *
 *  Binary format is 
 *  -records stored as 4byte floats
 *  ----------------------------------------------------------------*/

void printhelp(char* prog){
	printf("\n\n");
	printf("Usage: %s [opts] <file to convert>\n\n", prog);
	printf(" -b <ascii> <binout> create binary file from ascii (with .bin)\n");
	printf(" -d dump binary file \n");
	printf("This will take the mouse T31 alpha/nlp grid binary files and write out 20 text files that are flipped so I can reformat data to be 20145 rows but 232626 cols.\n");
	printf("Output filename is <inputname>.bin\n\n");
	exit(1);
}
void err(char* s){
	printf("**%s\n", s);
	printf("**exiting...\n");
	exit(1);
}


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

/********************************************
 * mouse alp/nlp grids are organized as 20145 across
 * and 232626 rows down (but i need it tranposed).
 *
 * this currently reads 12000 rows down, 20145 across
 * into an array and then writes as 20145 rows down
 * and 12000 across.
 *
 * to convert the whole dataset, I'll need to do this about 
 * 19+ times, then merge the output files
 *
 * *******************************************/
int pull_chunks(){
	//FILE* filein = fopen("alp_grid_scaled.bin", "rb");
	FILE* filein = fopen("nlp_perm_grid.bin", "rb");
	char name[64];
	long address = 0L;
	long total = 20145*12000;
	//printf("total = %ld\n", total);
	int ret=0;
	int counter=0;
	//float data[241740000];
	float* data;
	char num[5];
	data = (float*) malloc(20145*12000*sizeof(float));	
	if (data == NULL)
		err("could not allocate");
	
	//goto beg of file
	ret = fseek(filein, address, 0);
	if (ret==-1)
		err("count not seek to beginning");
	fprintf(stderr, "seek\n");
	// read 12,000 rows 19 times
	for (counter=1; counter<=19; counter++){
		fprintf(stderr, "counter=%d\n", counter);
		//build string name
		strcpy(name, "outputnlp");
		snprintf(num, 5,"%d", counter);
		strcat(name, num);
		strcat(name, ".txt");
		
		FILE* fileout = fopen(name, "w");
		ret = fread(data, sizeof(float), total, filein);
		if (ret!=total)
			err("did not seek total");
		fprintf(stderr, "read %d\n", counter);
	
		//write to text or binary?
		//20145 rows
		long ii=0;
		long jj=0;
		long pos=0;
		// i read 20145 across, write as 20145 down
		/*      1 2 ...      20145   
		 *    1 xxxxxxxxxxxx
		 *    2 yyyyyyyyyyyy
		 *    3 zzzzzzzzzzzz
		 *    .
		 *    232626
		 */
		for(ii=0; ii<20145; ii++){
			//fprintf(stderr, "line %ld of 20145\n", ii);
			// this makes 12000 columns 
			for(jj=0; jj<12000; jj++){
				//pos = ii*20145+jj;
				pos = (jj)*20145 + (ii);
				if (jj==11999)
					fprintf(fileout, "%f\n", data[pos]);
				else
					fprintf(fileout, "%f\t", data[pos]);
			}	
		}
		fclose(fileout);
	} //for 1..19
	
	//still need do the last chunk, only 4626 rows left
	
	fclose(filein); /* the bin file */
}

// the last chunk is only 4626 rows, handle separately!
int pull_last_chunk(){
	long offset = 0L;
	int ret = 0;
	float *data = (float*) malloc(20145*4626*sizeof(float));	
	//FILE* filein = fopen("alp_grid_scaled.bin", "rb");
	FILE* filein = fopen("nlp_perm_grid.bin", "rb");
	if (filein==NULL)
		err("cannot open bin file");
	offset = sizeof(float)* (19*12000*20145L); /*19 chunks of 12000 rows, ea 20145 cols */ 
	ret = fseek(filein, offset,0);
	if (ret != 0)
		err("cannot seek");
	ret = fread(data, sizeof(float), 20145*4626, filein); /* read in 20145cols,4626rows */
	if (ret != 20145*4626)
		err("did not read entire length");
fprintf(stderr, "outputing...\n");	
	FILE* fileout = fopen("outputnlp20.txt", "w");
	int ii=0;
	int jj=0;
	int pos=0;
	for (ii=0; ii<20145; ii++){
		for(jj=0; jj<4626; jj++){
			pos = (jj)*20145 + (ii);
			if (jj==4625)
				fprintf(fileout, "%f\n", data[pos]);
			else
				fprintf(fileout, "%f\t", data[pos]);
		}
	}
	fclose(fileout);
	fclose(filein);
}

int main(int argc, char* argv[]) {
	/*if (argc != 3 && argc !=4) { 
		printhelp(argv[0]);
	}
	*/
	int r;
pull_chunks();	
pull_last_chunk();

//	r = write_blank_file();
//	if (r)
//		printf("done writing file\n");
	/*r = flip_matrix();
	if (r)
		printf("done flipping file\n");
		*/
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

