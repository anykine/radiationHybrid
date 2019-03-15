# bash script to cat each dog chrom into a giant file
args=""
for i in `seq 1 39`;
do
	#pad the zeros
	num=$(printf '%02d' "$i");
	printf outcfa${num}.fasta
	printf " "
done
