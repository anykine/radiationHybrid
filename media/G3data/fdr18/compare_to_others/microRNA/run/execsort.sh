# sort the blastparse files
#sort -tk -k3n
# sort field 5 chars7-10, then by field 6
sort -k5.7,5.10 -k6,6n mblock10.txt
