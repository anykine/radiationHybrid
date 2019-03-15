for i in `seq 1 9`
do
	echo $i
	cat seq$i* > list$i
done
