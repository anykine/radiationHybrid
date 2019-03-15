#!/bin/bash

d=`date +%Y%m%d`
echo "incremental backups"
echo "backing up expr"
tar --newer '23 Sep 2009' --gzip --create --verbose --file rwang.home3.expr.$d.tar.gz /home3/rwang/expr
echo "backing up qtl comp"
tar --newer '23 Sep 2009' --gzip --create --verbose --file rwang.home3.qtlcomp.$d.tar.gz /home3/rwang/QTL_comp
echo "backing up cgh"
tar --newer '23 Sep 2009' --gzip --create --verbose --file rwang.home3.cgh.$d.tar.gz /home3/rwang/cgh
echo "backing up fdr"
tar --newer '23 Sep 2009' --gzip --create --verbose --file rwang.g3data.fdr.$d.tar.gz /media/G3data/fdr
echo "backing up fdr18"
tar --newer '23 Sep 2009' --gzip --create --verbose --file rwang.g3data.fdr18.$d.tar.gz /media/G3data/fdr18
echo "backing up mm7tohg18"
tar --newer '23 Sep 2009' --gzip --create --verbose --file rwang.g3data.mm7tohg18.$d.tar.gz /media/G3data/mm7tohg18
echo "backing up mouse data"
tar --newer '23 Sep 2009' --gzip --create --verbose --file rwang.g3data.mousedata.$d.tar.gz /media/G3data/mouse_data
