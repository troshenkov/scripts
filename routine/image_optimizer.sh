#!/bin/sh

# Dmitry Troshenkov (troshenkov.d@gmail.com)
#
# Image optimizer for the web
#

_PATH=/home/                                                                                                                                                                        
                                                                                                                                                                                    
SCRIPT_NAME=$(basename $(test -L "$0" && readlink "$0" || echo "$0"))                                                                                                               
                                                                                                                                                                                    
JO_INSTALL() {
echo -e 'Need to install jpegoptim
wget http://www.kokkonen.net/tjko/src/jpegoptim-1.4.2.tar.gz
zcat jpegoptim-1.4.2.tar.gz  | tar xf -
cd jpegoptim-1.4.2
./configure
make
make strip
make install'
}

OP_INSTALL() {
echo -e 'Need to install optipng
wget http://prdownloads.sourceforge.net/optipng/optipng-0.7.5.tar.gz
zcat optipng-0.7.5.tar.gz | tar xf -
cd optipng-0.7.5
make
make install'
}

if [[ ! -s ${_PATH} ]]; then echo The ${_PATH} 'not exist'; exit 0; fi
if hash jpegoptim 2>/dev/null; then JO=`which jpegoptim` ; else JO_INSTALL; exit 0; fi
if hash optipng 2>/dev/null; then OP=`which optipng` ; else OP_INSTALL; exit 0; fi

echo 'Before size:' $(du -sh ${_PATH}) >> ${SCRIPT_NAME}.log
find ${_PATH} -iregex '.*\.\(jpg\|JPG\|jpeg\|JPG\)' -type f -exec ${JO} {} --max=80 --strip-all ';' 1>/dev/null >> ${SCRIPT_NAME}.log
find ${_PATH} -iregex '.*\.\(png\|PNG\)' -type f -exec ${OP} {} ';' 2>/dev/null >> ${SCRIPT_NAME}.log
echo 'After size:' $(du -sh ${_PATH}) >> ${SCRIPT_NAME}.log
exit 0
