for i in *.pdf
do
	# % removes substring from end, match everything between dot and pdf
	filename=${i%.*pdf}
	# use quotes b/c of space in name
	convert "$filename.pdf" "$filename.jpg"
	#convert $i $i
done
