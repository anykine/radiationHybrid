for i in rh* 
do
		if [ ${#i} == 4 ]
		then
			echo $i 
			list=$list\ $i
		else
			#echo $i 
			#list=$list\ $i
		  echo "skip"	
		fi

done
echo $list
#paste $list > g3cghmatrix.txt
