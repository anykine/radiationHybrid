#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "/home/rwang/tut/bin/g3dataaccess/split/g3bin.h"
/*--------------------------------------------------------------------
 * Flips the G3 binary format (alp_grid_scaled.bin,
 * nlp_grid.bin) that are 20996 rows and 235829 cols into a series of 20
 * text files that are each 20145 rows, 12000/4626 cols. These will
 * later be merged into one file. This is necessary to get human and mouse data
 * files to be in the same order.
 *
 *  No guarantee that this is multi-platform compatible
 *
 * Expects input format: 
 *  20996 rows, each with 235829 columns 
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


/********************************************
 allocate an array of g3_records

********************************************/
g3_record_t* allocate_g3_record_array(int n){
	if (n < 1)
		err("allocate of g3 array failed");
	g3_record_t* data = malloc(NUMMARKERS * n * sizeof(g3_record_t));
	if (data == NULL)
		err("malloc failed");
	return data;
}

/********************************************
 * G3 data is currently stored as a matrix of 
 * 20996 rows and 235829 cols of g3_structs.
 *
 * To transpose the matrix, I read 300 rows X 235829 cols
 * at a time, write them to separate files and 
 * in another program, merge the output.
 *
 * To convert the whole dataset, I'll need to do this about 
 * 69+ times, then merge the output files
 *
 * G3 binary format is:
 *  - header
 *  - 20145 rows (genes)
 *  - 235829 columns (markers)
 * *******************************************/
int pull_chunks(){
	// need to add file header to offset
	
	int numrowstopull = 300;
	g3_head_t header;
	g3_record_t rec;

	char name[64];
	char num[5]; /* filename */
	long address = 0L;
	long total = NUMMARKERS*numrowstopull;
	int ret=0;
	int counter=0;

	FILE* filein = fopen("../g3alpha_model_results1.bin", "rb");
	if (filein == NULL)
		err("cannot open g3 binary file");		
	
	// store data	 (235829*300*20bytes = 1.4GB)
	g3_record_t* data = allocate_g3_record_array(numrowstopull);
	
	//goto beg of file
	ret = fseek(filein, address, 0);
	if (ret==-1)
		err("count not seek to beginning");

	// read the header
	ret = fread(&header, sizeof(g3_head_t), 1, filein);
	//g3_printheader(&header);

	fprintf(stderr, "seek\n");
	// read 300 rows(genes) 69 times, each has 235829 cols
	for (counter=1; counter<=69; counter++){
		fprintf(stderr, "counter=%d\n", counter);
		
		//build string name
		strcpy(name, "g3output");
		snprintf(num, 5,"%d", counter);
		strcat(name, num);
		strcat(name, ".txt");
		
		FILE* fileout = fopen(name, "w");
		if (fileout == NULL)
			err("file open for write failed");

		//NOTE: every call to fread advances the location pointer
		ret = fread(data, sizeof(g3_record_t), total, filein);
		if (ret!=total)
			err("did not seek total");
		fprintf(stderr, "read %d\n", counter);
	
		//write to text or binary?
		// 235829 rows
		long ii=0;
		long jj=0;
		long pos=0;
		// i read 235829 across, write as 235829 down
		/*      1 2 ...      235829
		 *    1 xxxxxxxxxxxx
		 *    2 yyyyyyyyyyyy
		 *    3 zzzzzzzzzzzz
		 *    .
		 *    20996
		 */
		for(ii=0; ii<NUMMARKERS; ii++){
			//fprintf(stderr, "line %ld of 20145\n", ii);
			// this makes 12000 columns 
			for(jj=0; jj<numrowstopull; jj++){
				
				// write out one after another
				pos = (jj)*NUMMARKERS+ (ii);
				fprintf(fileout, "%d\t%d\t", data[pos].gene_id, data[pos].marker_id);
				fprintf(fileout, "%f\t%f\t", data[pos].mu, data[pos].alpha);
				fprintf(fileout, "%f\n", data[pos].nlp);

				/*
				if (jj==numrowstopull-1)
					fprintf(fileout, "%f\n", data[pos].nlp);
				else
					fprintf(fileout, "%f\t", data[pos].nlp);
					*/
			}	
		}
		fclose(fileout);
	} //for 1..69
	
	//still need do the last chunk, only 296 rows left
	
	fclose(filein); /* the bin file */
}


// the last chunk is only 296 rows, handle separately!
// 20996 - 69*300 = 20996-20700 = 296
int pull_last_chunk(){
	int numrowstopull = 296;
	long total = NUMMARKERS * numrowstopull;
	long offset = 0L;
	int ret = 0;

	g3_record_t* data = allocate_g3_record_array(numrowstopull);
	FILE* filein = fopen("../g3alpha_model_results1.bin", "rb");
	if (filein == NULL)
		err("cannot open g3 binary file");		
	
	// don't forget to add G3 header
	offset = sizeof(g3_head_t)+sizeof(g3_record_t)* (69L*300L*NUMMARKERS); /*69 chunks of 300 rows, ea 235829cols */ 
	ret = fseek(filein, offset,0);
	if (ret != 0)
		err("cannot seek");

	ret = fread(data, sizeof(g3_record_t), total, filein); /* read in 20145cols,4626rows */
	if (ret != total)
		err("did not read entire length");

fprintf(stderr, "outputing...\n");	

	FILE* fileout = fopen("g3output70.txt", "w");
	int ii=0;
	int jj=0;
	int pos=0;
	for (ii=0; ii<NUMMARKERS; ii++){
		for(jj=0; jj<numrowstopull; jj++){
			pos = (jj)*NUMMARKERS+ (ii);
			fprintf(fileout, "%d\t%d\t", data[pos].gene_id, data[pos].marker_id);
			fprintf(fileout, "%f\t%f\t", data[pos].mu, data[pos].alpha);
			fprintf(fileout, "%f\n", data[pos].nlp);

		}
	}
	fclose(fileout);
	fclose(filein);
}

int main() {
	int r;
	pull_chunks();	
	//pull_last_chunk();

	//convert2bin(argv[1]);	
	//dumpbin(argv[1]);
	
}

