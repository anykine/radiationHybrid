#include<stdio.h>
#include <math.h>
/*to compile: gcc -O5 -o ../bin/rhserver_engine rhserver_engine.c -lm*/

float calcLOD();
/*./a.out ../rhdata/rhdata G3 0 3 10 11000000000000001000000000000010000100000000010000001010000001000000100001000000001 

11111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000
*/

/*global values to hold parameters*/
char vector[100];
char datadir[200];
char rhpanel[10];
char chromnum[3];
int lodcuttoff;
int numtoreturn;
char markername[11][20];

float LOD[11];
char chrom[11][3];
float distance[11];
char vectormatch[11][100];

int compnum=0;

int number_of_hybrids=0; char tempchrom[3];
char name[15]; char lvector[100];
FILE * INPUT;


void main(int argc,char *argv[])
{   int x,y; char filename[200];
/*Get the paramters
no checking is done as this called from script
1 input data dir (where the sucked rhdata is located
2 rhpanel (used to build up the name of teh file in input dir
3 chromosome number (0 for all)
4 number to return above lod threshold
5 lod threshold expressed at integer
6 the vector of scores 1000001000100100000111000R11111000000
 */
sscanf(argv[1],"%s",&datadir);
sscanf(argv[2],"%s",&rhpanel);
sscanf(argv[3],"%s",&chromnum);
sscanf(argv[4],"%d",&lodcuttoff);
sscanf(argv[5],"%d",&numtoreturn);
sscanf(argv[6],"%s",&vector);
number_of_hybrids=strlen(vector);
/*printf("%d\n",number_of_hybrids);*/

/*printf("%s,%s,%c,%d,%d,%s",datadir,rhpanel,chromnum,lodcuttoff,numtoreturn,vector);*/


/*set up the insertion sort*/

for(x=0;x<11;x++)
{LOD[x]=0;
distance[x]=100000;
strcpy(markername[x],"");
strcpy(chrom[x],"");
strcpy(vectormatch[x],"");


}


if(chromnum[0]=='0')
{ for(x=1;x<=22;x++)
	{sprintf(filename,"%s/%s.%d",datadir,rhpanel,x);
	/*printf("%s\n",filename);*/
	if(INPUT = fopen(filename,"r"))
	{sprintf(tempchrom,"%d",x);
	 docomp();
	fclose(INPUT);

	}
	else
	{printf ("Sorry couldn't open filename %s\n",filename);	}
	}

	sprintf(filename,"%s/%s.X",datadir,rhpanel);
	/*printf("%s\n",filename);*/
	if(INPUT = fopen(filename,"r"))
	{
	sprintf(tempchrom,"X");
	docomp();
	fclose(INPUT);
	
	}
	else
	{printf ("Sorry couldn't open filename %s\n",filename);	}
	sprintf(tempchrom,"Y");
	sprintf(filename,"%s/%s.Y",datadir,rhpanel);
	/*printf("%s\n",filename);*/
	if(INPUT = fopen(filename,"r"))
	{docomp();
	fclose(INPUT);

	}
	else
	{printf ("Sorry couldn't open filename %s\n",filename);	}


}

else 

{	sprintf(filename,"%s/%s.%s",datadir,rhpanel,chromnum);
	/*printf("%s\n",filename);*/
	if(INPUT = fopen(filename,"r"))
	{sprintf(tempchrom,"%s",chromnum);
	docomp();
	fclose(INPUT);

	}
	else
	{printf ("Sorry couldn't open filename %s\n",filename);	}


}


/*PRINT OUT THE ANSWER*/
printf("%d\n",compnum);
if(LOD[0]<lodcuttoff || LOD[0]==0)
{printf ("No marker matched above the given lod score cutoff\n");}
else{printf("#\tSHGCNAME\tCHROM#\tLOD_SCORE\tDIST.(cRs)\n\n");
	for(x=0;x<numtoreturn;x++)
	{if(LOD[x]<lodcuttoff){break;}
printf("%d\t%s\t%s\t",x+1,markername[x],chrom[x]);
printf("%2.2f\t\t%2.0f\nVector:%s\n\n",LOD[x]+.0049,distance[x]+0.49,vectormatch[x]); 

	}
}




}



int storesorted(char m[],float l, char c[3],float d,char vec[100])
{int x,y;
/*printf("%s %f %s %f %s\n",m,l,c,d,vec);*/

if(l<=LOD[9])return;


for(x=8;x>=0;x--)
	{if(l<LOD[x])break;
	}

for(y=8;y>x;y--)
	{
strcpy(markername[y+1],markername[y]);
LOD[y+1]=LOD[y];
strcpy(chrom[y+1],chrom[y]);
distance[y+1]=distance[y];
strcpy(vectormatch[y+1],vectormatch[y]);
	}


strcpy(markername[x+1],m);
LOD[x+1]=l;
strcpy(chrom[x+1],c);
distance[x+1]=d;
strcpy(vectormatch[x+1],vec);

} 






float calcLOD(char m1[], char m2[], int numhyb)
{float aa=0,ap=0,pp=0,pa=0,tothyb=0;int x,y; float retention; float ltheta, lod;
 float theta; float distance; float l1; int dup=0;
for(x=0;x<numhyb;x++)
	{ if(m1[x]=='0'){
			if(m2[x]=='0'){aa+=1;}
			else if(m2[x]=='1'){ap+=1;}	
			}
	  else if(m1[x]=='1'){		
			if(m2[x]=='0'){pa+=1;}
			else if(m2[x]=='1'){pp+=1;}	

				}
	}

tothyb=aa+ap+pp+pa;
retention=0.5*(((2.0*pp)+ap+pa)/tothyb);
theta=0.5*(pa+ap)/(tothyb*retention*(1.0-retention));
if(theta > 1.0){theta=1.0;}
else if(theta <0){theta=0;}


distance=(float)100.0*((-1.0)*(double)(log((double)(1.0-theta))));


l1=pp*log10(pow(retention,2.0))+(pa+ap)*log10(retention*(1.0-retention))+aa*log10(pow((1.0-retention),2));

if(theta==1.0){	ltheta=l1; lod=0;	}
else if(theta==0){
		ltheta=pp*log10((1.0-theta)*retention+theta*pow(retention,2.0)) + aa*log10((1.0-theta)*(1.0-retention)+theta*pow((1.0-retention),2.0));

	
			lod=ltheta-l1; dup=1;
		}
else{ ltheta=pp*log10((1.0-theta)*retention+theta*pow(retention,2.0)) + (pa+ap)*log10(theta*retention*(1.0-retention)) + aa*log10((1.0-theta)*(1.0-retention)+theta*pow((1.0-retention),2.0));

	lod=ltheta-l1;
	}

/*printf("%f %f %f %f %f %f %d %d %d %d\n",lod,ltheta,l1, distance,retention,theta,aa,ap,pp,pa);*/
if(aa==0 || pp==0){/*printf("%f %f %f %f %f %f %f %f %f %f %s\n",lod,ltheta,l1, distance,retention,theta,aa,ap,pp,pa,m2);*/
		lod=0;distance=1000;

		}
if(dup){strcat(name,"(D)");}

storesorted(name,lod,tempchrom,distance,m2);


}


int docomp()
{while(fscanf(INPUT,"%s %s",name,lvector)==2)
{calcLOD(vector,lvector,number_of_hybrids);compnum++;
}
}
