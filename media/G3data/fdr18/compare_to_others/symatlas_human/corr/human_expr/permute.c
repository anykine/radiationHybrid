#include <stdio.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_permutation.h>
#include <math.h>

// use half the 12,368*12,368 matrix
#define LEN 76489896 
//#define LEN 10


void print_time(){
	struct timeval tv;
	struct tm* ptm;
	char time_string[40];
	long milliseconds;

	gettimeofday(&tv, NULL);
	ptm=localtime(&tv.tv_sec);
	strftime(time_string, sizeof(time_string), "%Y-%m-%d %H:%M:%S", ptm);
	milliseconds = tv.tv_usec/1000;
	printf("%s.%03ld\n", time_string, milliseconds);
}

void* err(char* msg){
	printf("%s\n", msg);
	exit(-1);
}

double* allocate_double_array(int size){
	double* p = malloc(size * sizeof(double));
	if (p==NULL)
		err("could not allocate array");
	return p;
}

void* read_file_into_array(char* file, double** array ){
	FILE* f = fopen("t.cor", "r");
	if (f==NULL)
		err("cannot read flie");
	int i=0;
	double num=0.0;
	while(fscanf(f, "%lf", num) != EOF){
		*(*array+i) = num;
		printf("%lf\n", *(*array+i));
		i++;
	}
}

/*--------------------------------
 *
 * Calculate the Frobenius norm
 * from the observed ata
 * ------------------------------*/
double calculate_obs_frobenius(){

	printf("starting...loading human\n");
	print_time();

	int size = LEN;
	// the array of correlations
	double* human = allocate_double_array(size);
	int i;
	FILE* f = fopen("human_correlation_halfmatrix.txt","r");
	//FILE* f = fopen("t.cor", "r");
	if (f==NULL)
		err("cannot open human correlation");

	i=0;
	double num=0.0;
	// read in human correlatoins
	while(fscanf(f, "%lf ", &num) != EOF){
		*(human+i) = num;
		i++;
	}
	fclose(f);

	printf("done loading human\nnow loading gnf\n");
	print_time();
	
	//f = fopen("t.gnf", "r");
	f = fopen("../gnf_correlation_halfmatrix.txt", "r");
	if (f==NULL)
		err("cannot open gnf correlation");

	// subtract gnf correlations
	i=0;
	while( fscanf(f, "%lf", &num) != EOF){
		//printf("%lf\n", num);
		*(human+i) -= num;
		i++;
	}

	printf("done loading gnf\nstart Fnorm calc\n");
	print_time();
	
	// calculate L2 norm
	double result=0.0;
	for (i=0; i<size; i++){
		//printf("%lf\n ", *(human+i));
		result += (human[i] * human[i]);
	}
	//printf("%lf", result);

	printf("done calculating Fnorm\n");
	print_time();
	return(sqrt(result));
}

double calculate_perm_frobenius(int nperm){
	int size = LEN;
	int i;

	// --------------------------------
	//permutation stuff
	// --------------------------------
	const size_t N = LEN;
	const gsl_rng_type* T;
	gsl_rng* r;

	gsl_permutation* p = gsl_permutation_alloc(N);
	gsl_rng_env_setup();
	T = gsl_rng_default;
	r = gsl_rng_alloc(T);

	gsl_permutation_init(p);

	
	// --------------------------------
	// load human array of correlations
	// --------------------------------
	double* human = allocate_double_array(size);
	FILE* f = fopen("human_correlation_halfmatrix.txt","r");
	//FILE* f = fopen("t.cor", "r");
	if (f==NULL)
		err("cannot open human correlation");

	i=0;
	double num=0.0;
	// read in human correlatoins
	while(fscanf(f, "%lf ", &num) != EOF){
		*(human+i) = num;
		i++;
	}
	fclose(f);

	// --------------------------------
	// load gnf array of correlations
	// --------------------------------
	double* gnf = allocate_double_array(size);
	//f = fopen("t.gnf", "r");
	f = fopen("../gnf_correlation_halfmatrix.txt", "r");
	if (f==NULL)
		err("cannot open gnf correlation");

	// gnf correlations
	i=0;
	num=0.0;
	while( fscanf(f, "%lf", &num) != EOF){
		//printf("%lf\n", num);
		*(gnf+i) = num;
		i++;
	}
	fclose(f);

	// --------------------------------
	// calculate permuted L2 norm
	// --------------------------------
	double result=0.0;
	double temp=0.0;
	int j=0;
	int perm=0;
	for (perm=0; perm < nperm; perm++){
		fprintf(stderr, "permutation %d\n", perm);
		gsl_ran_shuffle(r, p->data, N, sizeof(size_t));
		for (i=0; i<size; i++){
			//printf("%lf\n ", *(human+i));
			j = gsl_permutation_get(p, i);
			//printf("%d ", j);
			temp = human[i] - gnf[j];
			result += (temp*temp);
			temp=0.0;
		}
		printf("%lf\n", (sqrt(result)));
		result = 0.0;
		//printf("\n");
	}
}


void test_permute(){

	print_time();
	printf(" init permutation stuff\n");
	const size_t N = LEN;
	const gsl_rng_type* T;
	gsl_rng* r;

	gsl_permutation* p = gsl_permutation_alloc(N);
	gsl_rng_env_setup();
	T = gsl_rng_default;
	r = gsl_rng_alloc(T);

	gsl_permutation_init(p);

	print_time();
	printf(" done init permutation stuff...starting pemutation\n");

	gsl_ran_shuffle(r, p->data, N, sizeof(size_t));

	print_time();
	printf(" done permutation ...starting pemutation\n");

	gsl_ran_shuffle(r, p->data, N, sizeof(size_t));

	print_time();
	printf(" done permutation\n");
}

int main(int argc, char* argv[]) {

	// calculate the Fnorm
	
	/*
	double ans = calculate_obs_frobenius(); 
	printf("obs fnorm = %lf\n", ans);	
	exit(1);
	*/
	
	// calculate the permuted Fnorm	
	//calculate_perm_frobenius(1000);
	calculate_perm_frobenius(3);
}
