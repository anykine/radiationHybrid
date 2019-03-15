files="/home3/rwang/cgh/run3a/US*.txt /home3/rwang/cgh/run3b/US*.txt"
for file in $files
do
	if [ ! -e $file ]; then
		echo "ERROR $file does not exist"
	else 
		echo "$file does exist"
	fi
done
