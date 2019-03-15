#!/usr/bin/bash
# run blat on human genome with params
#  no header
#  min match

for i in `seq 1 21`;
do
	echo $i
	#/home/rwang/bin/blat -t=dna -q=dna -noHead /drive2/mm7/chr$i.fa cisneg_probes.txt.fa cisneg_probe$i.psl
	#run2
	#/home/rwang/bin/blat -t=dna -q=dna -stepSize=5 -repMatch=2253 -minScore=30 -minIdentity=50 -noHead /drive2/mm7/chr$i.fa cisneg_probes.txt.fa cisneg_probe$i.psl
	#/home/rwang/bin/blat -t=dna -q=dna -stepSize=5 -repMatch=2253 -minScore=30 -minIdentity=50 -noHead /drive2/mm7/chr$i.fa cispos_probes.txt.fa cispos_probe$i.psl
	#run3
	#/home/rwang/bin/blat -t=dna -q=dna -stepSize=5 -repMatch=2253 -minScore=25 -minIdentity=25 -noHead /drive2/mm7/chr$i.fa cisneg_probes.txt.fa run3/cisneg_probe$i.psl
	#/home/rwang/bin/blat -t=dna -q=dna -stepSize=5 -repMatch=2253 -minScore=25 -minIdentity=25 -noHead /drive2/mm7/chr$i.fa cispos_probes.txt.fa run3/cispos_probe$i.psl
	#run 4
	#/home/rwang/bin/blat -t=dna -q=dna -stepSize=5 -repMatch=2253 -minScore=0 -minIdentity=0 -noHead /drive2/mm7/chr$i.fa cisneg_probes.txt.fa run4/cisneg_probe$i.psl
	/home/rwang/bin/blat -t=dna -q=dna -stepSize=5 -repMatch=2253 -minScore=0 -minIdentity=0 -noHead /drive2/mm7/chr$i.fa cispos_probes.txt.fa run4/cispos_probe$i.psl
done

#also need to run for X and Y chroms
