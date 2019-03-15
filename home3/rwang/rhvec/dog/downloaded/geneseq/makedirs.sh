# bash script to untar each dog chrom into its own dir
for i in `seq 1 39`;
do
	#pad the zeros
	num=$(printf '%02d' "$i");
	echo $num
	echo cfa$num
	mkdir cfa$num
	cd cfa$num
	tar xvf ../CFA$num.tar
	cd ..
done
