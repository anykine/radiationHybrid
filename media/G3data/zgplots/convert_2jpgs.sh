	if [ -e "jpgs" ]
		then echo "directory jpgs exists"
		else 
			mkdir jpgs
	fi
for j in *.pdf
do
	echo $j
	# % removes substring from end, match everything between dot and pdf
	filename=${j%.*pdf}
	# use quotes b/c of space in name
	convert "$filename.pdf" "jpgs/$filename.jpg"
done



#for i in *.pdf
#do
#	# % removes substring from end, match everything between dot and pdf
#	filename=${i%.*pdf}
#	# use quotes b/c of space in name
#	convert "$filename.pdf" "jpgs/$filename.jpg"
#done
