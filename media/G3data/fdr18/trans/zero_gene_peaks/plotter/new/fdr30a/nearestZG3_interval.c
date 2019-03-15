#include <gd.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

#define PCT_MARGIN 0.90
/******************************************************

Plot nearest 0-gene eqtls for mouse in human genome
orig to do the synteny plot, map human genes to mouse chroms

10/20/08
plot mouse in red on left, human in blue on right of each chrom

9/16/2009
Changed to read in two files: one of human block positions, 
another file with mouse block positions (converted to human coords)
*******************************************************/
int main(int argc, char* argv[]){

	gdImagePtr im;
	FILE *fchrom, *fpos, *fout;
	char *fnchrom, *fnhumpos, *fnmuspos;

	float sizex, sizey;
	int numchroms;
	double human_chrom[24];			//size of chroms 0..23
	char* names_human_chrom[24];
	
	//read in size file
	fnchrom = argv[1];
	fnhumpos = argv[2];
	fnmuspos = argv[3];
	sizex = atof(argv[4]);
	sizey = atof(argv[5]);
	
	
	if (argc != 6) {
		usage(argv[0]);
	}
	
	fchrom = fopen(fnchrom, "r");
	if (!fchrom) {
		fprintf(stderr, "cannot open chrom file\n");
		exit(-1);
	}
	
	fout = fopen("output.png", "w");
	if (!fout) { exit(-1);}
	
	char* s;
	float f;
	float scale;
	int ii;
	
	char buffer[256];
	printf("reading chrom sizes\n");
	numchroms = 0;
	while( fscanf(fchrom, "%s %f", buffer, &f) != EOF){
		human_chrom[numchroms] = f/1000000.0;
		//names_human_chrom[numchroms] = buffer;
		names_human_chrom[numchroms] = malloc(strlen(buffer)* sizeof(char));
		strcpy(names_human_chrom[numchroms], buffer);
		//printf("%f\n", human_chrom[numchroms]);
		//printf("%s\n", s);
		printf("%s\n", names_human_chrom[numchroms]);
		numchroms++;
	}

	//figure out a few things
	scale = sizey/human_chrom[0] * PCT_MARGIN	; 		//90% the size of the requested size		
	int xcoordstep = sizex * PCT_MARGIN/numchroms;	//hum chrom stepsize
	int marginx = sizex*(1-PCT_MARGIN)/2;
	int marginy = sizey*(1-PCT_MARGIN)/2;
	int brect[8];
	/*******************************
		Create Image
	*********************************/
	im = gdImageCreate(sizex, sizey);
	printf("start image creation\n");
	
	int white = gdImageColorAllocate(im, 255,255,255);
	int black = gdImageColorAllocate(im, 0,0,0);	
	int red = gdImageColorAllocate(im, 255,0,0);
	int blue = gdImageColorAllocate(im, 0,0,255);
	int grey = gdImageColorAllocate(im, 187, 187, 187);
	//int red = gdImageColorAllocateAlpha(im, 255,0,0,64);
	//int blue = gdImageColorAllocateAlpha(im, 0,0,255,64);
	int colors[21];
	
	for (ii=1; ii <22; ii++){
		colors[ii] = gdImageColorAllocate(im, floor(255/8*ii), floor(128/7*ii), floor(216/5*ii));
	}
	
	/******************************
		Draw Chroms
	******************************/
	printf("draw chroms\n");
	char sbuf[24];
	
	for (ii=0; ii<numchroms; ii++){
		
		gdImageLine(im, marginx+ii*xcoordstep, sizey-marginy, 
					marginx+ii*xcoordstep, sizey-marginy-human_chrom[ii]*scale,black);
		
		sprintf(sbuf,"%d",ii+1);
		gdImageStringFT(im, brect, black,"/home/rwang/tut/plotlarge/arialbd.ttf", 8, 0., marginx+ii*xcoordstep, sizey-marginy+12,  sbuf);
	}

	
	/***********************************
		Read human file
		something like 'zero_gene_peaks3_ranges300k.txt'
	************************************/
	printf("reading positions\n");
	fpos = fopen(fnhumpos, "r");
	if (!fpos){
		fprintf(stderr, "cannot open human file\n");
		exit(-1);
	}
	int muschr, humchr;
	float start, end;
	int xcoord;
	int radius = 5;
	float ycoord,ycoord1, ycoord2;
	int mstart, mend, chromstart, chromend;
	float posstart, posend;
	float posavg;
	float mpos, hpos;
	float my, mx, hy, hx;
	char tag;
	ii=0;
	
	// Beware of chrX or chr_random, fscanf will not match EOF if not converted!
	// file format is 
	// start marker | chrom | start pos | end marker | chrom | end pos
	while( fscanf(fpos, "%d %f %f %c", &chromstart, &posstart, &posend, &tag) != EOF){
		//printf("%d %d %f %f %s\n", muschr, humchr, start, end,buffer);
		printf("%d %f %f %c\n", chromstart, posstart, posend, tag);
		// average the start/stop positions, yes it could overflow...
		posavg = (posstart+posend)/2;
		hx = marginx + (chromstart-1)*xcoordstep;
		hy = sizey-marginy-human_chrom[chromstart-1]*scale+ posavg/1000000*scale;
		//printf("%f %f %f %f\n", mx,my,hx,hy);
		ycoord1 = sizey-marginy-human_chrom[chromstart-1]*scale+posstart/1000000*scale;
		ycoord2 = sizey-marginy-human_chrom[chromstart-1]*scale+posend/1000000*scale;
		
		// new, plot mouse on left(red), hum on right(blue)
	
		//gdImageLine(im, hx, hy, hx+radius, hy, blue); /*human*/
		
		// if overlap, draw in red, use rects instead of lines
		if (tag == 'o'){
			//gdImageFilledRectangle(im, hx, ycoord1, hx+radius, ycoord2, red);
			//gdImageRectangle(im, hx, ycoord1, hx+radius, ycoord2, black);
			gdImageLine(im, hx, hy, hx+radius, hy, red); /*human*/
		} else {
			//gdImageFilledRectangle(im, hx, ycoord1, hx+radius, ycoord2, grey);
			//gdImageRectangle(im, hx, ycoord1, hx+radius, ycoord2, black);
			//gdImageRectangle(im, hx, ycoord1, hx+radius, ycoord2, grey);
			gdImageLine(im, hx, hy, hx+radius, hy, grey); /*human*/
		}

	}
	fclose(fpos);	
	/***********************************
		read mouse chrom file
	    hum_zerogene_block_pos.txt
	************************************/
	printf("reading positions\n");
	fpos = fopen(fnmuspos, "r");
	if (!fpos){
		fprintf(stderr, "cannot open mouse file\n");
		exit(-1);
	}

	while( fscanf(fpos, "%d %f %f %c", &chromstart, &posstart, &posend, &tag) != EOF){
		posavg = (posstart+posend)/2;
		mx = marginx + (chromstart-1)*xcoordstep;
		my = sizey-marginy-human_chrom[chromstart-1]*scale + posavg/1000000*scale;
		//gdImageLine(im, mx-radius, my, mx, my, red); /*mouse*/

		ycoord1 = sizey-marginy-human_chrom[chromstart-1]*scale+posstart/1000000*scale;
		ycoord2 = sizey-marginy-human_chrom[chromstart-1]*scale+posend/1000000*scale;
		//
		// overlapping guy is in red
		if (tag=='o'){
			//gdImageFilledRectangle(im, mx-radius, ycoord1, mx, ycoord2, red);
			//gdImageRectangle(im, mx, ycoord1, mx-radius, ycoord2, black);
			gdImageLine(im, mx-radius, my, mx, my, red); /*mouse*/
		} else {
			//gdImageFilledRectangle(im, mx-radius, ycoord1, mx, ycoord2, grey);
			//gdImageRectangle(im, mx, ycoord1, mx-radius, ycoord2, black);
			gdImageLine(im, mx-radius, my, mx, my, grey); /*mouse*/
		}
	}
	fclose(fpos);

	/***********************************
		print human centromeric regions
	************************************/
	printf("adding centromere\n");
	//fpos = fopen("hg18centromere_gap1.txt", "r");
	fpos = fopen("../../centromere/hg18_centromere_final.txt", "r");
	if (!fpos){
		fprintf(stderr, "cannot open centromeric positions\n");
		exit(-1);
	}

	while( fscanf(fpos, "%d %f %f", &chromstart, &posstart, &posend) != EOF){
		hx = marginx + (chromstart-1)*xcoordstep;
		ycoord1 = sizey-marginy-human_chrom[chromstart-1]*scale+posstart/1000000*scale;
		ycoord2 = sizey-marginy-human_chrom[chromstart-1]*scale+posend/1000000*scale;
		//gdImageRectangle(im, hx-radius, ycoord1, hx+radius, ycoord2, black);
		gdImageFilledRectangle(im, hx-radius, ycoord1, hx+radius, ycoord2, black);
	}
	gdImagePng(im,fout);
	gdImageDestroy(im);
	fclose(fout);
	//gdImageLine(im, 10, sizey-10, 10, sizey-human_chrom[ii]*scale, red);
	

}

int usage(char* s){
	fprintf(stderr, "%s <chrom size> <human input> <mouse input> <size x> <size y>\n", s);
	exit(-1);
}
