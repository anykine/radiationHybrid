#!/bin/bash

for dir in RH_c*; do
names=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y)
prefix="$dir/${dir}_chr"

for i in ${names[@]}; do
#for i in `seq -w1 1 24`; do
	# if numeric
	if [ $i -eq $i 2> /dev/null ]; then
		if [ $i -lt 10 ]; then
			list=$list\ "${prefix}0$i.pdf"
		else 
			list=$list\ "$prefix$i.pdf"
		fi
	else
		list=$list\ "$prefix$i.pdf"
	fi
done
echo $list
#file="${prefix}s.pdf"
file=$dir/all${dir}.pdf
#merge the pdfs into one file
gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=$file -dBATCH $list

#need to clear list variable
$list=
#delete files
#rm $list

done
