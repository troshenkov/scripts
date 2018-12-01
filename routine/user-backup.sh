#!/bin/bash

# Dmitry Troshenkov (troshenkov.d@gmail.com)

DATE=`date +%x-%X`
FROM_DIR=/home/user
BACKUP_DIR=/home/user-backup
DAYS_BACK=5

test -d $BACKUP_DIR || mkdir -p $BACKUP_DIR

find $FROM_DIR/. -mtime -$DAYS_BACK \(          \
                -name "*.xls"                   \
                -o -name "*.docx"               \
                -o -name "*.txt"                \
                -o -name "*.pdf"                \
                -o -name "*.doc"                \
                -o -name "*.odt"                \
                -o -name "*.rtf"                \
                -o -name "*.sxw"                \
                -o -name "*.xml"                \
                -o -name "*.html"               \
                -o -name "*.ppt"                \
                -o -name "*.pps"                \
                -o -name "*.odt" \) -exec       \
        tar jcpf $BACKUP_DIR/'back'$DAYS_BACK'days'-$DATE.tar.bz2 --exclude=$BACKUP_DIR \{\} \;
#END

exit 0
