# automate the pipline

# split cis trans
echo "step1"
./split_cis_and_trans_fdr_thresh.pl

#sort by gene
echo "step2"
sort -k1g -k2g mouse_cis_alpha_nothresh.txt -T /media/usbdisk/ -o mouse_cis_alpha_nothresh_sorted.txt

#find peaks
echo "step3"
./find_cis_peaks2.pl
