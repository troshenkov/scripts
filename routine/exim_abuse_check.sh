#!/bin/bash

EMAIL=you@domain.tld
LOG=MESSAGE

_COUNT=50
_QUEUE=$(exim -bpr | grep "@" | wc -l)

if [ ${_QUEUE} -gt ${_COUNT} ] ; then
        echo Queue: ${_QUEUE} >> ${LOG}
        echo $(exim -bpr | grep "@" | sort | uniq -c) >> ${LOG}
        echo "+++++++++++++++++++" >> ${LOG}
        echo "Abuse:" >> ${LOG}
        echo $(cat /var/log/exim_mainlog | grep 'has exceeded the max defers and failures per hour' | awk '{ print $8 }' | sort | uniq -c) >> ${LOG}
        cat ${LOG} | mailx -s "Exim using on the `hostname` (`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`)" ${EMAIL};
        rm -f ${LOG};
fi

exit 0;
