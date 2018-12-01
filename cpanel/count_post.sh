#!/bin/bash

# Dmitry Troshenkov (troshenkov.d@gmail.com)

_COUNT=200

for i in `find /usr/local/apache/domlogs  -type f`; do

        tmp=`cat $i |grep POST | sort | uniq -c | wc -l`

                if [ ${tmp} -gt ${_COUNT} ] ; then

                        echo -e ${tmp} " "  ${i}

                fi

done

exit 0

