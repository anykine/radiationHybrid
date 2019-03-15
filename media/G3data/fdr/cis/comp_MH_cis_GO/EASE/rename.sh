for i in  *.txt; do
	#echo $i
	newname=${i:0:23}.GO
	mv -T "${i}" ${newname}
	#echo $i $newname
done
