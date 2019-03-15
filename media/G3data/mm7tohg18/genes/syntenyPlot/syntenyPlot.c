#include <gd.h>
#include <stdlib.h>
#include <stdio.h>
#include <mysql.h>
#include <math.h>
#include <string.h>

#define PCT_MARGIN 0.90
/******************************************************

Do the synteny plot, map human genes to mouse chroms


*******************************************************/
int main(int argc, char* argv[]){

	gdImagePtr im;
	FILE *fchrom, *fpos, *fout;
	char *fnchrom, *fnpos;

	float sizex, sizey;
	int numchroms;
	double human_chrom[24];			//size of chroms 0..23
	char* names_human_chrom[24];
	
	//read in size file
	fnchrom = argv[1];
	fnpos = argv[2];
	sizex = atof(argv[3]);
	sizey = atof(argv[4]);
	
	
	if (argc != 5) {
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
		Read file
	************************************/
	printf("reading positions\n");
	fpos = fopen(fnpos, "r");
	if (!fpos){
		fprintf(stderr, "cannot open chrom file\n");
		exit(-1);
	}
	int muschr, humchr;
	float start, end;
	int xcoord;
	int radius = 5;
	float ycoord,ycoord1, ycoord2;
	ii=0;
	
	// Beware of chrX or chr_random, fscanf will not match EOF if not converted!
	while( fscanf(fpos, "%d %d %f %f %s", &muschr, &humchr, &start, &end, &buffer) != EOF){
		//printf("%d %d %f %f %s\n", muschr, humchr, start, end,buffer);
		//xcord based on muschr
		xcoord = marginx+(humchr-1)*xcoordstep;
		ycoord = sizey-marginy-human_chrom[humchr-1]*scale+start/1000000*scale;
		ycoord1 = sizey-marginy-human_chrom[humchr-1]*scale+start/1000000*scale;
		ycoord2 = sizey-marginy-human_chrom[humchr-1]*scale+end/1000000*scale;
		//printf("%d %f %f\n", xcoord, ycoord1, ycoord2);
		
		//each chrom gets a color based on muschr
		//gdImageLine(im, xcoord-radius, ycoord, xcoord+radius, ycoord, colors[muschr]);
		gdImageFilledRectangle(im, xcoord-radius, ycoord1, xcoord+radius, ycoord2, colors[muschr]);
		//ii++;
		//if (ii > 3) break;
	}
	
	/***********************************
		mouse chrom colors
	************************************/
	
	int rectsize=10;
	
	for (ii=1; ii<22; ii++){
		gdImageFilledRectangle(im, marginx+sizex/21*0.90*ii-rectsize, rectsize, marginx+sizex/21*0.90*ii+rectsize, 2*rectsize, colors[ii]);
		
		gdImageStringFT(im, brect, black,"/home/rwang/tut/plotlarge/arialbd.ttf", 6, 0., marginx+sizex/21*0.90*ii, 2*rectsize+15,  names_human_chrom[ii-1]);
	}

	gdImagePng(im,fout);
	gdImageDestroy(im);
	fclose(fout);
	//gdImageLine(im, 10, sizey-10, 10, sizey-human_chrom[ii]*scale, red);
	

/*
	MYSQL *conn;
	MYSQL_RES *res;
	MYSQL_ROW row;

	char *server = "localhost";
	char *user = "root";
	char *password = "smith1";
	char *database = "mouse_rhdb";
	conn = mysql_init(NULL);

	if (!mysql_real_connect(conn, server, user, password, database, 0, NULL, 0)){
		fprintf(stderr, "%s\n", mysql_error(conn));
		exit(1);
	}
	if (mysql_query(conn, "select probename, genome_coord from probe_gc_final1;")){
		fprintf(stderr, "%s\n", mysql_error(conn));
		exit(1);
	}
	res = mysql_use_result(conn);
	printf("MySQL tables in mysql database:\n");
	while((row = mysql_fetch_row(res)) != NULL)
		printf("%s %s\n", row[0], row[1]);
	mysql_free_result(res);
	mysql_close(conn);
	*/
}

int usage(char* s){
	fprintf(stderr, "%s <chrom size> <input> <size x> <size y>\n", s);
	exit(-1);
}
