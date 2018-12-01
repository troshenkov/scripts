#!/bin/bash

NNOV_IP_RANGE=`curl http://files.unn.ru/ixnn.txt | grep -v ':'`

HTA='nnov_htaccess'

:> ${HTA}

echo 'Order Deny,Allow' >> ${HTA}
echo 'Deny from all' >> ${HTA}

for ip in ${NNOV_IP_RANGE} ; do

	echo ${ip} | sed s/^/"Allow from "/ >> ${HTA}

done
