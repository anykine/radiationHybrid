simvec = function(size){
	a1=rbinom(size,1,0.25)	
	a2=rbinom(size,1,0.25)	
	a3=rbinom(size,1,0.25)	
	a4=rbinom(size,1,0.25)	
	cat("\n",a1,"\n",a2,"\n",a3,"\n",a3,"\n")
	sumofvec = a1+a2+a3+a4
	cat("\n",sumofvec,"\n")
	sumofvec
}
