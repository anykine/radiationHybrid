#include <stdio.h>

/*********************************************
Richard Wang

Creates a 2d matrix of 1's and 0's of rhvec data
and then marks horizontal and vertical streaks.
       y 
   0 0 0 0 0
   0 1 1 0 0 
x  0 1 1 0 0 
   0 1 1 0 0 
   0 0 0 0 0 
***********************************************/
/* globals */
#define MAX	20 
#define debug 1 

char* matrix[MAX]; 			//holds our matrix data
int max_x = MAX-1;				//indexing is 0based, so -1
int max_y = MAX-1;

int usage(){
	printf("program <input file> <num markers>\n"); 
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
/* --------------------------
Outputs the marked markers 
----------------------------*/
void readout() {
	int x,y;
	for (x=0; x<=max_x; x++){
		for (y=x; y<=max_y; y++){
			//add 1 to match input file
			if (matrix[x][y] == 2) printf("%d\t%d\n", x+1,y+1);
		}
	}
}
/* --------------------------
Outputs the current matrix
----------------------------*/
void print_matrix(char** matrix){
	int i,j, tab;
	//rows
	for (i=0; i < MAX; i++){
		//print out the spaces to align the 1/2 matrix
		for(tab = 0; tab <= i; tab++){
			printf("  ");
		}
		//cols
		for (j=i; j<MAX; j++){
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
00000000
 0000000
   00000
    0000
     000
      00
       0
----------------------------*/
void alloc_matrix(){
	//create 2d matrix and init to 0
	//to be efficient, i can create 1/2 matrix
	int index1,index2;
	for (index1=0; index1<MAX; index1++){
		matrix[index1] = malloc(MAX-index1 * sizeof(char));
		if (matrix[index1]==NULL){
			errout("mem allocation failed for matrix!");
		}	
	}
}

/*--------------------------
initialize matrix to zero
---------------------------*/
void init_matrix(){
	//init to 0
	int index1,index2;
	for (index1=0; index1<MAX; index1++){
		for (index2=index1; index2<MAX; index2++){
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
		matrix[m1-1][m2-1] = 1;
	}
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
		printf("%s ", "zero");
	} else {
		t("testing");
		// top left
		if (x==0 && y==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0) {
			t("top left");
			matrix[x][y]=2;
			count = 1 + search_horiz(x,y+1);
		}
		// top right
		else if (x==0 && y==max_y && (matrix[x][y-1]==0 || matrix[x][y-1]==2) &&
			matrix[x+1][y-1]==0 && matrix[x+1][y]==0){
			t("top right");
			if (matrix[x][y] == 1){
				t("top right2");
				matrix[x][y]=2;
				count = 1; 
			}
		}
		// top
		else if (x==0 && (matrix[x][y-1]==0 || matrix[x][y-1]==2) && 
			matrix[x+1][y-1]==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0) {
			t("top");
			matrix[x][y]=2;
			count = 1 + search_horiz(x,y+1);
		}
		//bot left
		else if (x==max_x && matrix[x-1][y]==0 && matrix[x-1][y+1]==0 && y==0){
			matrix[x][y]=2;
			count = 1 + search_horiz(x,y+1);
		}
		//close to bot right
		else if (x==max_x && (matrix[x][y-1]==0 || matrix[x][y-1]==2) && matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && y==max_y){
			if (matrix[x][y] == 1) {
				count = 1;
				matrix[x][y]=2;
			}
		}
		// bottom
		else if (x==max_x && (matrix[x][y-1]==0 || matrix[x][y-1]==2) && matrix[x-1][y-1]==0 && matrix[x-1][y]==0 && 
			matrix[x-1][y+1] ==0) {
			t("x @ bottom");
			matrix[x][y]=2;
			count = 1 + search_horiz(x, y+1);
		}
		// left 
		else if (y==0 && matrix[x-1][y]==0 && matrix[x-1][y+1]==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0) {
			t("left");
			matrix[x][y]=2;
			count = 1 + search_horiz(x, y+1);
		}
		//right
		else if (y==max_y && matrix[x-1][y]==0 && matrix[x-1][y-1]==0 &&  matrix[x+1][y-1]==0 && matrix[x+1][y]==0) {
			t("right");
			matrix[x][y]=2;
			count = 1 + search_horiz(x, y+1);
		}
		//8 of 9 are 0, right side is 1
		else if (matrix[x-1][y+1]==0 && matrix[x-1][y] ==0 &&  matrix[x-1][y-1]==0 && 
			(matrix[x][y-1]==0 || matrix[x][y-1]==2) &&
			matrix[x+1][y-1]==0 && matrix[x+1][y]==0 && matrix[x+1][y+1]==0) {
				t("1found one");
				matrix[x][y]=2;
				count = 1 + search_horiz(x, y+1);
		} else {
			t("exiting");
		}
		//mark for deletion
	}
	return count;
}
/*************************************************
//if spot has no neighbors, mark for deletion

*************************************************/
int remove_speck(int x, int y){
	int count = 0;
	//8 exceptional cases, plus the norm
	t("starting");
	//top left corner
	if (x == 0 && y==0)	{
		t("one");
		count = matrix[x][y+1] + matrix[x+1][y+1] + matrix[x+1][y];
	//top right corner
	} else if (x == 0 && y == max_y) {
		t("two");
		count = matrix[x][y-1] + matrix[x+1][y-1] + matrix[x+1][y];
	//bottom left corner
	} else if (x == max_x && y == 0){
		t("three");
		count = matrix[x-1][y] + matrix[x-1][y-1] + matrix[x][y+1];
	//bottom right corner
	} else if (x == max_x && y == max_y) {
		t("four");
		count = matrix[x][y-1] + matrix[x-1][y-1] + matrix[x-1][y];
	//left side
	} else if (x == 0) {
		t("five");
		count = matrix[x][y-1] + matrix[x+1][y-1] + matrix[x+1][y] + matrix[x+1][y+1] + matrix[x][y+1];
	//top
	} else if (y == 0) {
		t("six");
		count = matrix[x][y-1] + matrix[x-1][y+1] + matrix[x+1][y] + matrix[x+1][y+1] + matrix[x][y+1];
	//right side
	} else if (x == max_x) {
		t("seven");
		count = matrix[x][y-1] + matrix[x-1][y-1] + matrix[x-1][y] + matrix[x-1][y+1] + matrix[x][y+1];
	//bottom
	} else if (y == max_y) {
		t("eight");
		count = matrix[x-1][y] + matrix[x-1][y-1] + matrix[x][y-1] + matrix[x+1][y-1] + matrix[x+1][y];
	//all other cases...
	} else {
		t("case Z");
		count = matrix[x-1][y-1] + matrix[x-1][y] + matrix[x-1][y+1] + 
			matrix[x][y-1] + matrix[x][y+1] + 
			matrix[x+1][y-1] + matrix[x+1][y] + matrix[x+1][y+1];
	}
	if (count ==0) {
		matrix[x][y] = 2;
		t("setting to zero");
	}
	return count;
}

void readout();

int main(int argc, char** argv){
	if (argc != 3) usage();

	alloc_matrix();
	init_matrix();
	load_matrix(argv[1]);
	print_matrix(matrix);
	//int c = search_horiz(1,1);
	// use matrix coords (subtract 1 from marker #)

	//remove speck code works
	int x,y;
	for (x=0; x<=max_x; x++){
		for (y=x; y <=max_y; y++){
			int c= remove_speck(x,y);
		}
	}
	// start from left, top
	// search horiz works
	//int c =search_horiz(5,10);
	//printf("count=%d\n", c);
	//int c = remove_speck(0,9);
	print_matrix(matrix);
	//readout();
}

