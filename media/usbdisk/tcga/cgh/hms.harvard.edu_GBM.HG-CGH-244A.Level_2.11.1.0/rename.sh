for fil in `ls *.tsv`
do
   newfil=`echo $fil | sed -e 's/95_Feb07/10_Apr08/g'`
   mv $fil $newfil
done
