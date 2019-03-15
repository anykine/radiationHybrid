#!/bin/bash

# convert the mouse alp/nlp bin fiiles to text
# now merge the text files. all this to flip the matrix.
for i in `seq 1 20`
do
	# this was for alphas
	#list=$list\ output$i.txt

	# this is for nlps
	list=$list\ outputnlp$i.txt
done
echo $list

#paste $list > /drive2/mus_alp_scaled_grid.txt
paste $list > /drive2/mus_nlp_perm_grid.txt

