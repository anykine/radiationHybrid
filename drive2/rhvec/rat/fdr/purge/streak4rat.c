#include <stdio.h>
#include <stdlib.h>

/*********************************************
$Id: streak.c,v 1.9 2008-01-05 01:41:32 rwang Exp $
Richard Wang

Creates a 2d matrix of 1's and 0's of rhvec data
and then marks horizontal and vertical streaks and
single points for removal. Setting a value to 2
marks it for removal.

Note, data is stored as 2d matrix, but I only use
the upper half triangle for data storage and searching.
I don't create a half triangle because it throws off
numbering when I output.

		       y 
   0 0 0 0 0 0 0 0 0 0
   0 0 0 0 0 0 0 0 0 0
   0 0 0 0 0 0 0 0 0 0
   0 0 0 0 0 0 0 0 0 0
x  0 0 0 0 0 0 0 0 0 0
   0 0 0 0 0 0 0 0 0 0
   0 0 0 0 0 0 0 0 0 0
   0 0 0 0 0 0 0 0 0 0
   0 0 0 0 0 0 0 0 0 0
   0 0 0 0 0 0 0 0 0 0
   
   
   (we use this triangle, indexed as so)
   1      ---->      9
    y 
1  1 1 1 1 1 1 1 1 1 1
   0 1 1 1 1 1 1 1 1 1
   0 0 1 1 1 1 1 1 1 1
   0 0 0 1 1 1 1 1 1 1
x  0 0 0 0 1 1 1 1 1 1
   0 0 0 0 0 1 1 1 1 1
   0 0 0 0 0 0 1 1 1 1
   0 0 0 0 0 0 0 1 1 1
   0 0 0 0 0 0 0 0 1 1
9  0 0 0 0 0 0 0 0 0 1

Internally I use zero-based arrays, but input data 
is 1-based. 
***********************************************/
/* globals */
#define debug 0 

//#ifdef debug
//#define MAX	20
//#else
#define MAX	19532
//#endif


char* matrix[MAX]; 			//holds our matrix data
int max_x = MAX-1;				//indexing is 0based, so -1
int max_y = MAX-1;

char memo[2]; //memoize
struct memo {
	int x1;
	int y1;
	int x2;
	int y2;
};

struct memo memo_struct;

FILE* fpspeck, *fpvstreak, *fphstreak;

void usage(){
	printf("program <input file> \n"); 
	exit(1);
}

//trace
void t(char* msg){
	if (debug){
		printf("test: %s\n", msg);
	}
}
void errout(char * err){
	printf("error: %s\n", err);
	exit(1);
}
void reset_memo(){
	memo_struct.x1 = -1;
	memo_struct.y1 = -1;
	memo_struct.x2 = -1;
	memo_struct.y2 = -1;
}
/* --------------------------
Outputs the marked markers (unused)
----------------------------*/
void readout() {
	int x,y;
	for (x=0; x<=max_x; x++){
		for (y=x; y<=max_y; y++){
			//add 1 to x,y to match input file which is zero-based
			if (matrix[x][y] == 2) printf("%d\t%d\n", x+1,y+1);
		}
	}
}
/* --------------------------
Outputs the current matrix
----------------------------*/
void print_matrix(char** matrix){
	int i,j;
	//rows
	for (i=0; i < MAX; i++){
		//cols
		for (j=0; j<MAX; j++){
			//prints out as digit (ascii -> num)
			printf("%d ", matrix[i][j]);
		}
		printf("\n");
	}
	printf("\n");
}

/* --------------------------
reserve memory for matrix
creates 2d array
----------------------------*/
void alloc_matrix(){
	//create 2d matrix and init to 0
	int index1,index2;
	for (index1=0; index1<MAX; index1++){
		matrix[index1] = malloc(MAX * sizeof(char));
		if (matrix[index1]==NULL){
			errout("mem allocation failed for matrix!");
		}	
	}
}

/*--------------------------
initialize matrix to zero
---------------------------*/
void init_matrix(){
	int index1,index2;
	for (index1=0; index1<MAX; index1++){
		for (index2=0; index2<MAX; index2++){
			matrix[index1][index2] = 0;
		}
	}
}
/*--------------------------
load file into matrix
markers are number 1..n but
matrix is 0-based
---------------------------*/
void load_matrix(char* file){
	FILE *fp;
	fp = fopen(file, "r");
	if (fp==NULL) errout("could not open input file\n");
	//read file
	unsigned int m1=0, m2=0; //store marker1,marker1
	float f1=0, f2=0;				//throwaway
	while(!feof(fp)){
		fscanf(fp, "%d %d %f %f", &m1, &m2, &f1, &f2);
		//subtract 1
		if (m1 > MAX || m2 > MAX) {
			errout("matrix size is too small");
		} else {
			matrix[m1-1][m2-1] = 1;
		}
	}
}//x,y are always pos, starting in upper left
int search_vert(int x, int y){
	int count;
	if (x<0 ||x>max_x || y<0 || y>max_y){
		t("out of bounds");
		count=0;
	} else if (matrix[x][y] == 0) {
		t("val is zero");
		count=0;		
	//  matrix[x][y]=1
	} else {
		t("testing");
		// handle all cases where matrix[x][y]=1
		//top row, can only be starts
		if (x==0){
			t("x==0 block");
			if (y==0){
				//do nothing
				reset_memo();
			}
			//start
			if (y==1 && matrix[x][y-1]==0 && matrix[x][y+1]==0 && matrix[x+1][y]==1 && matrix[x+1][y+1]==0){
				t("x=0, y=1");
				memo_struct.x1=x;
				memo_struct.y1=y;
				search_vert(x+1, y);
			} else if (y==max_y && matrix[x][y-1]==0 && matrix[x+1][y-1]==0 && matrix[x+1][y]==1) {
				t("last col");
				memo_struct.x1=x;
				memo_struct.y1=y;
				search_vert(x+1, y);
			} else if (matrix[x][y-1]==0 && matrix[x][y+1]==0 && matrix[x+1][y-1]==0 && matrix[x+1][y]==1 && matrix[x+1][y+1]==0){
				memo_struct.x1=x;
				memo_struct.y1=y;
				search_vert(x+1, y);
			}
			else {
				t("top FAIL");
				reset_memo();
			}
		}
		// end of row
		else if ( y == max_y ) {
			t("y==max_y block");
			//start @ top
			if (x==0 && matrix[x][y-1]==0 && matrix[x+1][y-1]==0 && matrix[x+1][y]==1){

				t("last col top start");
				memo_struct.x1=x;
				memo_struct.y1=y;
				search_vert(x+1,y);

			//end above right bot corner (start)
			} else if (x==max_x-1 && matrix[x-1][y-1]==0 && matrix[x-1][y]==0 &&
					matrix[x][y-1]==0 &&
					matrix[x+1][y]==1){

					t("ymax, start above");
					memo_struct.x1=x;
					memo_struct.y1=y;
					search_vert(x+1, y);

			//end above right bot corner (end)
			} else if (x==max_x-1 && matrix[x-1][y-1]==0 && matrix[x-1][y]==1 &&
					matrix[x][y-1]==0 &&
					matrix[x+1][y]==0){

					t("ymax, mid above");
					memo_struct.x2=x;
					memo_struct.y2=y;
			
			//end above right bot corner (mid)
			} else if (x==max_x-1 && matrix[x-1][y-1]==0 && matrix[x-1][y]==1 &&
					matrix[x][y-1]==0 &&
					matrix[x+1][y]==1){

					t("ymax, mid above");
					search_vert(x+1,y);

			//start general
			} else if (matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && 
					matrix[x][y-1]==0 &&
					matrix[x+1][y=1]==0 && matrix[x+1][y]==1){

					t("end of row start");
					memo_struct.x1=x;
					memo_struct.y1=y;
					search_vert(x+1,y);
			
			// stop general
			} else if ( matrix[x-1][y-1]==0 && matrix[x-1][y]==1 &&
						matrix[x][y-1]==0 && 
						matrix[x+1][y-1]==0 && matrix[x+1][y]==0 ) {

					t("end of row stop");
					memo_struct.x2=x;
					memo_struct.y2=y;
			
			//mid general
			} else if (matrix[x-1][y-1]==0 && matrix[x-1][y]==1 && 
					matrix[x][y-1]==0 && 
					matrix[x+1][y-1]==0 && matrix[x+1][y]==1) {

					t("end of row mid");
					search_vert(x+1,y);

			}
			else {

				t("right end FAIL");
				reset_memo();
			}
		} 
		// diag		
		else if (x==y ) {
			t("x==y block");
			// end only
			if (matrix[x-1][y-1]==0 && matrix[x-1][y]==1 && matrix[x-1][y+1]==0 && matrix[x][y+1]==0 && matrix[x+1][y+1]==0){
			
				t("diag");
				memo_struct.x2=x;
				memo_struct.y2=y;
				
			}
		}
		// off diag
		else if (y-1==x){
			t("y-1==x block");
			//start
			if (matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && matrix[x-1][y+1]==0 &&
				matrix[x][y-1]==0 && matrix[x][y+1]==0 &&
				matrix[x+1][y]==1 && matrix[x+1][y+1]==0) {

				t("one off start");
				memo_struct.x1=x;
				memo_struct.y1=y;
				search_vert(x,y+1);
			}
			//end
			else if (matrix[x-1][y-1]==0 && matrix[x-1][y]==1 && matrix[x-1][y+1]==0 &&
				matrix[x][y-1]==0 && matrix[x][y+1]==0 &&
				matrix[x+1][y]==0 && matrix[x+1][y+1]==0){

				t("one off end");
				memo_struct.x2=x;
				memo_struct.y2=y;
			}
			//mid
			else if(matrix[x-1][y-1]==0 && matrix[x-1][y]==1 && matrix[x-1][y+1]==0 &&
				matrix[x][y-1]==0 && matrix[x][y+1]==0 &&
				matrix[x+1][y]==1 && matrix[x+1][y+1]==0){

				t("one off mid");
				search_vert(x,y+1);
			}
			// NOT a streak
			else {
				t("one off clear");
				reset_memo();
			}
		
		// the general cases
		} else {
			t("gen case");
			count = 0;	
			//start
			if(matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && matrix[x-1][y+1]==0 &&
				matrix[x][y-1]==0 && matrix[x][y+1]==0 &&
				matrix[x+1][y-1]==0 && matrix[x+1][y]==1 && matrix[x+1][y+1]==0){

				t("1start...");
				//set start
				memo_struct.x1=x;
				memo_struct.y1=y;
				search_vert(x+1,y);
			}
			// end
			else if (memo_struct.x1 != -1 && matrix[x-1][y-1]==0 && matrix[x-1][y]==1 && matrix[x-1][y+1]==0 &&
				matrix[x][y-1]==0 && matrix[x][y+1]==0 &&
				matrix[x+1][y-1]==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0){

				t("1end...");
				//set end
				memo_struct.x2=x;
				memo_struct.y2=y;
			}
			//mid
			else if (memo_struct.x1 != -1 && matrix[x-1][y-1]==0 && matrix[x-1][y]==1 && matrix[x-1][y+1]==0 &&
				matrix[x][y-1]==0 && matrix[x][y+1]==0 &
				matrix[x+1][y-1]==0 && matrix[x+1][y]==1 && matrix[x+1][y+1]==0) {

				t("1mid...");
				search_vert(x+1,y);
			}
			// NOT a streak, reset all flags
			else {

				//clear
				t("12clear");
				reset_memo();
			}
		}//else matrix[x][y]==1
		
		
	}//else
	return count;
}

//x,y are always pos, starting in upper left
int search_horiz(int x, int y){
	int count;
	if (x<0 ||x>max_x || y<0 || y>max_y){
		t("out of bounds");
		count=0;
	} else if (matrix[x][y] == 0) {
		t("val is zero");
		count=0;		
	//  matrix[x][y]=1
	} else {
		t("testing");
		// handle all cases where matrix[x][y]=1
		//top row
		if (x==0){
			//upper left start
			if (y==0 && matrix[x][y+1]==1) {
				
				t("x=0,y=0");
				memo_struct.x1=x;
				memo_struct.y1=y;
				search_horiz(x,y+1);
			} 						
			// x=0, y=1 (end)
                       else if (y==1 && matrix[x][y-1]==1 && matrix[x][y+1]==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0){

				t("top one off end");
				memo_struct.x2=x;
				memo_struct.y2=y;
			}
			// x=0, y=1 (start)
			else if (y==1 && matrix[x][y-1]==0 && matrix[x][y+1]==1 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0){
                               
				t("top one-off start");
				memo_struct.x1=x;
				memo_struct.y1=y;	
				search_horiz(x,y+1);		
			}
			// x=0, y=1 (mid)
                       else if (y==1 && matrix[x][y-1]==1 && matrix[x][y+1]==1 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0){
                               t("top one-off mid");
				search_horiz(x,y+1);
			}
			// top right end
                       else if (y==max_y && matrix[x][y-1]==1 && matrix[x+1][y-1]==0 && matrix[x+1][y]==0){
                               t("top right end");
				memo_struct.x2=x;
				memo_struct.y2=y;
			}
			// top begin
                       else if (matrix[x][y-1]==0 && matrix[x][y+1]==1 &&
                               matrix[x+1][y-1]==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0){

				t("top streak begin");
				memo_struct.x1=x;
				memo_struct.y1=y;	
				search_horiz(x,y+1);
			}
			// top end
                       else if (matrix[x][y-1]==1 && matrix[x][y+1]==0 &&
                               matrix[x+1][y-1]==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0){

                               t("top end");
				memo_struct.x2=x;
				memo_struct.y2=y;
			}
			// top mid
                        else if (matrix[x][y-1]==1 && matrix[x][y+1]==1 &&
                               matrix[x+1][y-1]==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0){

				t("top mid");
				search_horiz(x,y+1);
			}
			else {
				t("top FAIL");
				reset_memo();
			}

			
		}
		// end of row
		else if ( y == max_y ) {
			//end only
			if (matrix[x-1][y-1]==0 && matrix[x-1][y]==0 &&
				matrix[x][y-1]==1 &&
				matrix[x+1][y-1]==0 && matrix[x+1][y]==0) {
			
				t("right end");
				memo_struct.x2=x;
				memo_struct.y2=y;
			}
			//above bot right corner end
			else if (x==max_x-1 && matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && matrix[x][y-1]==1 && matrix[x+1][y]==0){
				t("above right end");
				memo_struct.x2=x;
				memo_struct.y2=y;
			}
			else {

				t("right end FAIL");
				reset_memo();
			}
		} 
		// diag		
		else if (x==y ) {
			// start only
			if (matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && matrix[x][y+1]==1){
			
				t("diag");
				memo_struct.x1=x;
				memo_struct.y1=y;
				search_horiz(x,y+1);
			}
		}
		// off diag
		else if (y-1==x){
			//start
			if (matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && matrix[x-1][y+1]==0 &&
				matrix[x][y-1]==0 && matrix[x][y+1]==1 &&
				matrix[x+1][y]==0 && matrix[x+1][y+1]==0) {

				t("one off start");
				memo_struct.x1=x;
				memo_struct.y1=y;
				search_horiz(x,y+1);
			}
			//end
			else if (matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && matrix[x-1][y+1]==0 &&
				matrix[x][y-1]==1 && matrix[x][y+1]==0 &&
				matrix[x+1][y]==0 && matrix[x+1][y+1]==0){

				t("one off end");
				memo_struct.x2=x;
				memo_struct.y2=y;
			}
			//mid
			else if(matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && matrix[x-1][y+1]==0 &&
				matrix[x][y-1]==1 && matrix[x][y+1]==1 &&
				matrix[x+1][y]==0 && matrix[x+1][y+1]==0){

				t("one off mid");
				search_horiz(x,y+1);
			}
			// NOT a streak
			else {
				t("one off clear");
				reset_memo();
			}
		
		// the general cases
		} else {
			count = 0;	
			//start
			if(matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && matrix[x-1][y+1]==0 &&
				matrix[x][y-1]==0 && matrix[x][y+1]==1 &&
				matrix[x+1][y-1]==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0){

				t("1start...");
				//set start
				memo_struct.x1=x;
				memo_struct.y1=y;
				search_horiz(x,y+1);
			}
			// end
			else if (memo_struct.x1 != -1 && matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && matrix[x-1][y+1]==0&&
				matrix[x][y-1]==1 && matrix[x][y+1]==0 &&
				matrix[x+1][y-1]==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0){

				t("1end...");
				//set end
				memo_struct.x2=x;
				memo_struct.y2=y;
			}
			//mid
			else if (memo_struct.x1 != -1 && matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && matrix[x-1][y+1]==0 &&
				matrix[x][y-1]==1 && matrix[x][y+1]==1 &
				matrix[x+1][y-1]==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0) {

				t("1mid...");
				search_horiz(x,y+1);
			}
			// NOT a streak, reset all flags
			else {

				//clear
				t("1clear");
				reset_memo();
			}
		}//else matrix[x][y]==1
		
		
	}//else
	return count;
}
/*************************************************
//if spot has no neighbors, mark for deletion

the numbers below refer to the case to use
		       y 
   1 2 3 3 3 4 
   0 5 6 7 7 8 
   0 0 5 6 7 8 
x  0 0 0 5 6 8 
   0 0 0 0 5 9 
   0 0 0 0 0 X
*************************************************/
int remove_speck(int x, int y){
	//printf("x=%d y=%d\n", x, y);
	int count = 0;
	//10 cases
	t("starting");
	if (matrix[x][y] == 1){
		//top left corner (one)
		if (x == 0 && y==0)	{
			t("one");
			count = matrix[x][y+1] + matrix[x+1][y+1];
		//bottom right corner (ten)
		} else if (x == max_x && y == max_y) {
			t("ten");
			count = matrix[x-1][y-1] + matrix[x-1][y] ;
		//almost top left (two)
		} else if (x == 0 && y==1 ) {
			t("two");
			count = matrix[x][y-1] + matrix[x][y+1] + matrix[x+1][y] + matrix[x+1][y+1] ;
		//top right corner (four)
		} else if (x == 0 && y == max_y) {
			t("four");
			count = matrix[x][y-1] + matrix[x+1][y-1] + matrix[x+1][y];
		//diag (five)
		} else if (y == x) {
			t("five");
			count = matrix[x-1][y-1] + matrix[x-1][y] + matrix[x-1][y+1] + matrix[x][y+1] + matrix[x+1][y+1];
		//almost bottom right corner (nine)
		} else if (x == max_x-1 && y == max_y){
			t("nine");
			count = matrix[x-1][y-1] + matrix[x-1][y] + matrix[x][y-1] + matrix[x+1][y];
		//one off diag (six)
		} else if (y-1==x) {
			t("six");
			count = matrix[x][y-1] + matrix[x][y+1] + matrix[x+1][y] + matrix[x+1][y+1] ;
		//top (three)
		} else if (x == 0 && (y > 1 || y < max_y)) {
			t("three");
			count = matrix[x][y-1] + matrix[x][y+1] + matrix[x+1][y-1] + matrix[x+1][y] + matrix[x+1][y+1] ;
		//right (eight)
		} else if (y == max_y && (x>0 || x < max_y-1)) {
			t("eight");
			count = matrix[x-1][y-1] + matrix[x-1][y] + matrix[x][y-1] + matrix[x+1][y-1] + matrix[x+1][y];
		//all other cases...
		} else {
			// (seven)
			t("seven");
			count = matrix[x-1][y-1] + matrix[x-1][y] + matrix[x-1][y+1] + 
				matrix[x][y-1] + matrix[x][y+1] + 
				matrix[x+1][y-1] + matrix[x+1][y] + matrix[x+1][y+1];
		}
	}
	//output single points w/ user-friendly index
	if (count ==0 && matrix[x][y]==1) {
		matrix[x][y] = 0;
		fprintf(fpspeck,"%d\t%d\n", x+1,y+1);
		//printf("%d\t%d\n", x+1,y+1);
		//t("setting to zero");
	}
	return count;
}


int main(int argc, char** argv){
	if (argc != 2) usage();
//printf("size of max is %d", MAX);
	alloc_matrix();
	init_matrix();
	load_matrix(argv[1]);
	int x,y;
	
	//print_matrix(matrix);
	
	//remove speck code works
	fpspeck = fopen("output.speck", "w");
	if (fpspeck==NULL) errout("cannot open speck write file");
	//printf("---specs---\n");
	for (x=0; x<=max_x; x++){
		for (y=x; y <=max_y; y++){
			//printf("--spec test x=%d y=%d\n", x, y);
			int c= remove_speck(x,y);
		}
	}
	fclose(fpspeck);
	
	//remove streaks

	//printf("---horizstreaks---\n");
	reset_memo();
	fphstreak = fopen("output.hstreak", "w");
	if (fpspeck==NULL) errout("cannot open hstreak write file");
	for (x=0; x<=max_x; x++){
		for (y=x; y <=max_y; y++){
			int c =search_horiz(x,y);
			if (memo_struct.x1 != -1){
				//printf("startx=%d starty=%d endx=%d endy=%d\n", memo_struct.x1,
				//	memo_struct.y1, memo_struct.x2, memo_struct.y2);
				fprintf(fphstreak,"%d\t%d\t%d\t%d\n", memo_struct.x1+1,
					memo_struct.y1+1, memo_struct.x2+1, memo_struct.y2+1);
				reset_memo();
			}
		}
	}
	fclose(fphstreak);
	

	//printf("---vertstreaks---\n");
	reset_memo();
	fpvstreak = fopen("output.vstreak", "w");
	if (fpspeck==NULL) errout("cannot open vstreak write file");
	for (x=0; x<=max_x; x++){
		for (y=x; y <=max_y; y++){
			int c =search_vert(x,y);
			if (memo_struct.x1 != -1){
				//printf("call startx=%d starty=%d endx=%d endy=%d\n", memo_struct.x1,
				//	memo_struct.y1, memo_struct.x2, memo_struct.y2);
				fprintf(fpvstreak,"%d\t%d\t%d\t%d\n", memo_struct.x1+1,
					memo_struct.y1+1, memo_struct.x2+1, memo_struct.y2+1);
				reset_memo();
			}
		}
	}
	fclose(fpvstreak);

	
	// testing search vert
/*
	int c = search_vert(10,17);
	if (memo_struct.x1 != -1) {
		printf("call startx=%d starty=%d endx=%d endy=%d\n", memo_struct.x1,
			memo_struct.y1, memo_struct.x2, memo_struct.y2);
	}
*/	
	// testing search horiz
	/*
	int c =search_horiz(5,10);
	if (memo_struct.x1 != -1){
		printf("call startx=%d starty=%d endx=%d endy=%d\n", memo_struct.x1,
			memo_struct.y1, memo_struct.x2, memo_struct.y2);
	}
	*/
	
	// testing remove speck
	//int c = remove_speck(0,9);
	//print_matrix(matrix);
	//readout();
}

